#!/bin/bash

cp mwan3_auth.sh /usr/bin/mwan3_auth && chmod +x /usr/bin/mwan3_auth
cp mwan3_status.sh /usr/bin/mwan3_status && chmod +x /usr/bin/mwan3_status
cp curl_auth.sh /usr/bin/curl_auth && chmod +x /usr/bin/curl_auth
cp mwan3_auth.init /etc/init.d/mwan3_auth && chmod +x /etc/init.d/mwan3_auth


/etc/init.d/mwan3_auth enable
/etc/init.d/mwan3_auth start