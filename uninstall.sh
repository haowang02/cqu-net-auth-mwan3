#!/bin/bash

/etc/init.d/mwan3_auth stop
/etc/init.d/mwan3_auth disable


rm /usr/bin/mwan3_auth
rm /usr/bin/mwan3_status
rm /usr/bin/curl_auth
rm /etc/init.d/mwan3_auth