#!/bin/bash
# ===========================================设置相关参数=============================================
# 设置文件下载路径
FLIE_PATH=${FLIE_PATH:-'./'}

#设置AGO-token
TOK=${TOK:-'eyJhIjoiMzg2OGEzNjc2ZTkyZmUxMmY0NjM1YTU0ZmNhMDQ0NDMiLCJ0IjoiY2MzYzJlZmUtNWM1Zi00OWI4LWJlZDUtZGYyZDIyOGJmZmI5IiwicyI6IlpqYzVPRGs1WldJdE0yRTNPQzAwWlRNMExUa3labVF0TURNM016SmxPVEV4WkRZMyJ9'}

#设置哪吒
NZ_SERVER=${NZ_SERVER:-'data.seaw.gq'}
NZ_KEY=${NZ_KEY:-'afFsAK3sSwi0X1rUg8'}

#哪吒其他默认参数，无需更改
NZ_PORT=${NZ_PORT:-'443'}
NZ_TLS=${NZ_TLS:-'1'}
TLS=${NZ_TLS:+'--tls'}

# ===========================================设置下载链接=============================================

# 设置x86_64-AGO下载地址
 URL_CF=${URL_CF:-'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'}

# 设置x86_64-NZ下载地址
 URL_NZ=${URL_NZ:-'https://github.com/seav1/AGONodejs/raw/main/NZ-amd'}

# 设置x86_64-bot下载地址
 URL_BOT=${URL_BOT:-'https://seav-xr.hf.space/kano-6'}

# 设置arm-AGO下载地址
 URL_CF2=${URL_CF2:-'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'}

# 设置arm-NZ下载地址
 URL_NZ2=${URL_NZ2:-'https://github.com/seav1/AGONodejs/raw/main/NZ-arm'}

# 设置arm-bot下载地址
 URL_BOT2=${URL_BOT2:-'https://seav-xr.hf.space/kano-6-arm'}


# ===========================================下载相关文件=============================================
arch=$(uname -m)
if [[ $arch == "x86_64" ]]; then
# 下载AGO
if [[ -n "${TOK}" ]]; then
[ ! -e ${FLIE_PATH}nginx.js ] && curl -sLJo ${FLIE_PATH}nginx.js ${URL_CF}
fi
# 下载NZ
if [[ -n "${NZ_SERVER}" && -n "${NZ_KEY}" ]]; then
[ ! -e ${FLIE_PATH}NZ.js ] && curl -sLJo ${FLIE_PATH}NZ.js ${URL_NZ}
fi
# 下载bot
if [[ -z "${BOT}" ]]; then
[ ! -e ${FLIE_PATH}bot.js ] && curl -sLJo ${FLIE_PATH}bot.js ${URL_BOT}
fi
else
# 下载AGO
if [[ -n "${TOK}" ]]; then
[ ! -e ${FLIE_PATH}nginx.js ] && curl -sLJo ${FLIE_PATH}nginx.js ${URL_CF2}
fi
# 下载NZ
if [[ -n "${NZ_SERVER}" && -n "${NZ_KEY}" ]]; then
[ ! -e ${FLIE_PATH}NZ.js ] && curl -sLJo ${FLIE_PATH}NZ.js ${URL_NZ2}
fi
# 下载bot
if [[ -z "${BOT}" ]]; then
[ ! -e ${FLIE_PATH}bot.js ] && curl -sLJo ${FLIE_PATH}bot.js ${URL_BOT2}
fi
fi
# ===========================================运行程序=============================================
# 运行NZ
if [[ -n "${NZ_SERVER}" && -n "${NZ_KEY}" && -s "${FLIE_PATH}NZ.js" ]]; then
chmod +x ${FLIE_PATH}NZ.js
nohup ${FLIE_PATH}NZ.js -s ${NZ_SERVER}:${NZ_PORT} -p ${NZ_KEY} ${TLS} >/dev/null 2>&1 &
fi

# 运行bot
if [[ -z "${BOT}"  && -s "${FLIE_PATH}bot.js" ]]; then
chmod +x ${FLIE_PATH}bot.js
nohup ${FLIE_PATH}bot.js >/dev/null 2>&1 &
fi

# 运行AGO
if [[ -n "${TOK}" && -s "${FLIE_PATH}nginx.js" ]]; then
chmod +x ${FLIE_PATH}nginx.js
TOK=$(echo ${TOK} | sed 's@cloudflared.exe service install ey@ey@g')
nohup ${FLIE_PATH}nginx.js tunnel --edge-ip-version auto run --token ${TOK} >/dev/null 2>&1 &
fi

# 运行serves
if [[ -s "./serves" ]]; then
chmod 777 ./serves
./serves
fi


# ===========================================显示系统信息=============================================
#===系统信息====
echo "----- 系统信息...----- ."
cat /proc/version

# ===========================================显示进程信息=============================================
if command -v ps -ef >/dev/null 2>&1; then
   fps='ps -ef'
elif command -v ss -nltp >/dev/null 2>&1; then
   fps='ss -nltp'
else
   fps='0'
fi
num=$(${fps} |grep -v "grep" |wc -l)
echo "$num"

if [ "$num" -ge  "4" ]; then
echo "----- 系统进程...----- ."
${fps} | sed 's@--token.*@--token ${TOK}@g;s@-s data.*@-s ${NZ_SERVER}@g;s@tunnel.*@tunnel@g'
fi
# ===========================================运行进程守护程序=============================================

# 检测bot
function check_bot(){
  count=$(${fps} |grep $1 |grep -v "grep" |wc -l)
if [ 0 == $count ];then
  # count 为空
  echo "----- 检测到bot未运行，重启应用...----- ."
  nohup ${FLIE_PATH}bot.js >/dev/null 2>&1 &
else
  # count 不为空
  echo "bot is running......"
fi
}

# 检测nginx
function check_cf (){
 count=$(${fps} |grep $1 |grep -v "grep" |wc -l)
if [ 0 == $count ];then
  # count 为空
    echo "----- 检测到nginx未运行，重启应用...----- ."
     nohup ${FLIE_PATH}nginx.js tunnel --edge-ip-version auto run --token ${TOK} >/dev/null 2>&1 &
else
  # count 不为空
    echo "nginx is running......"
fi
}
# 检测NZ
function check_NZ(){
 count=$(${fps} |grep $1 |grep -v "grep" |wc -l)
if [ 0 == $count ];then
  # count 为空
  echo "----- 检测到NZ未运行，重启应用...----- ."
nohup ${FLIE_PATH}NZ.js -s ${NZ_SERVER}:${NZ_PORT} -p ${NZ_KEY} ${TLS} >/dev/null 2>&1 &
else
  # count 不为空
  echo "NZ is running......" 
fi
}


# 循环调用检测进程
while true
do
if [ "$num" -ge  "4" ]; then
  [ -s ${FLIE_PATH}bot.js ] && check_bot ${FLIE_PATH}bot.js
  sleep 10
  [ -s ${FLIE_PATH}nginx.js ] && check_cf ${FLIE_PATH}nginx.js
  sleep 10
  [ -s ${FLIE_PATH}NZ.js ] && check_NZ ${FLIE_PATH}NZ.js
  sleep 10
  echo "完成一轮检测，60秒后进入下一轮检测"
  sleep 60
else 
  echo "App is running"
  sleep 666666
fi
done