#!/bin/sh
set -e

# 1. Konfig mentés
BACKUP=/root/config-backup-$(date +%Y%m%d%H%M%S).xml
cp /conf/config.xml "$BACKUP"

# 2. Reboot utáni visszatöltő script előkészítése
cat > /usr/local/etc/rc.d/restore_config.sh << 'EOF'
#!/bin/sh
# KEYWORD: firstboot

. /etc/rc.subr

name="restore_config"
start_cmd="restore_config_start"

restore_config_start()
{
    BACKUP=$(ls -t /root/config-backup-*.xml | head -1)
    if [ -f "$BACKUP" ]; then
        cp "$BACKUP" /conf/config.xml
        echo "Konfig visszaállítva: $BACKUP"
        # Önmagát törli, hogy ne fusson újra
        rm /usr/local/etc/rc.d/restore_config.sh
        /usr/local/etc/rc.reload_all
    fi
}

load_rc_config $name
run_rc_command "$1"
EOF

chmod +x /usr/local/etc/rc.d/restore_config.sh

# 3. Teljes tiszta újratelepítés (rebootol)
opnsense-bootstrap -f -y -t community -r 25.1
