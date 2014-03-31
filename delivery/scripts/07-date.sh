#! /bin/bash

echo '#! /bin/bash
if [ $(/bin/date +%Y) -lt 1971 ]; then /bin/date --set 2014-01-01; fi' > /etc/init.d/avoid1970

chmod a+rx /etc/init.d/avoid1970
update-rc.d avoid1970 defaults
