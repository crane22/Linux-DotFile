function printIP() {
  ipPublic=$(curl --silent ipinfo.io/ip)
  echo "Current Public IP: ${ipPublic}"
}
function proxyConnect() {
  proxyIP="127.0.0.1"
  proxyPort="44944"
  proxySocks5="socks5://${proxyIP}:${proxyPort}"
  proxyHTTP="http://${proxyIP}:${proxyPort}"
  proxySSH="${proxyIP}:${proxyPort}"
  # System Proxy
  export http_proxy="${proxyHTTP}"
  export HTTP_PROXY="${proxyHTTP}"
  export https_proxy="${proxyHTTP}"
  export HTTPS_PROXY="${proxyHTTP}"
  export ftp_proxy="${proxyHTTP}"
  export FTP_PROXY="${proxyHTTP}"
  # export rsync_proxy="${proxyHTTP}"
  # export RSYNC_PROXY="${proxyHTTP}"
  export ALL_PROXY="${proxySocks5}"
  export all_proxy="${proxySocks5}"
  # Git Proxy
  git config --global http.https://github.com.proxy ${proxyHTTP}
  # SSH Github Proxy
  if ! grep -qF "Host github.com" ~/.ssh/config ; then
      echo "Host github.com" >> ~/.ssh/config
      echo "    ProxyCommand nc -X 5 -x ${proxySSH} %h %p" >> ~/.ssh/config
      echo "    User git" >> ~/.ssh/config
  else
      sed -i "/Host github.com/a\    ProxyCommand nc -X 5 -x ${proxySSH} %h %p" ~/.ssh/config
  fi
  # APT Proxy
  echo "Acquire::http::Proxy \"${proxyHTTP}\";" | sudo tee /etc/apt/apt.conf.d/proxy.conf >/dev/null 2>&1
  echo "Acquire::https::Proxy \"${proxyHTTP}\";" | sudo tee -a /etc/apt/apt.conf.d/proxy.conf >/dev/null 2>&1
  printIP
}
function proxyDisconnect() {
  # System Proxy
  unset http_proxy
  unset HTTP_PROXY
  unset https_proxy
  unset HTTPS_PROXY
  unset ftp_proxy
  unset FTP_PROXY
  # unset rsync_proxy
  # unset RSYNC_PROXY
  unset ALL_PROXY
  unset all_proxy
  # Git Proxy
  git config --global --unset http.https://github.com.proxy
  # SSH Github Proxy
  lineNum=$(($(awk '/Host github.com/{print NR}'  ~/.ssh/config)+1))
  sed -i "${lineNum}d" ~/.ssh/config
  # APT Proxy
  sudo rm /etc/apt/apt.conf.d/proxy.conf
  printIP
}
alias pcon="proxyConnect"
alias pdis="proxyDisconnect"
alias ptst="curl -I https://google.com"
alias pprt="printIP"
# End of lines to set proxies