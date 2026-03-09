#!/bin/sh
set -e

# 1. Konfig mentés
BACKUP=/root/config-backup-$(date +%Y%m%d%H%M%S).xml
cp /conf/config.xml "$BACKUP"
echo "Konfig mentve: $BACKUP"

# 2. Reboot utáni visszatöltő script írása (heredoc nélkül)
RESTORE=/usr/local/etc/rc.d/restore_config.sh

printf '#!/bin/sh\n' > $RESTORE
printf 'BACKUP=$(ls -t /root/config-backup-*.xml | head -1)\n' >> $RESTORE
printf 'if [ -f "$BACKUP" ]; then\n' >> $RESTORE
printf '    cp "$BACKUP" /conf/config.xml\n' >> $RESTORE
printf '    echo "Konfig visszaallitva"\n' >> $RESTORE
printf '    rm %s\n' "$RESTORE" >> $RESTORE
printf '    /usr/local/etc/rc.reload_all\n' >> $RESTORE
printf 'fi\n' >> $RESTORE

chmod +x $RESTORE
echo "Restore script elkeszult: $RESTORE"

# 3. Bootstrap
opnsense-bootstrap -f -y -t community -r 25.1
