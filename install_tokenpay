wget https://github.com/LightCountry/TokenPay/releases/download/v1.0.8.1/release-linux-x64.zip

if ! command -v unzip >/dev/null 2>&1; then
   yum install unzip
fi
if [ -d "/token_pay" ]; then
    rm -rf /token_pay
    mkdir /token_pay
else
    mkdir /token_pay
fi
unzip release-linux-x64.zip -d /token_pay
rm -r ./release-linux-x64.zip
echo "TokenPay 已完成安装 目录:/token_pay"
