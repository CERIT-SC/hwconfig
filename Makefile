FQDN=$(shell hostname -f)

# HP Scripting Toolkit for Linux 9.50
URL_HPST=https://ftp.hp.com/pub/softlib2/software1/pubsw-linux/p1221080004/v84368/hp-scripting-toolkit-linux-9.50.tar.gz

# IBM Advanced Settings Utility 9.63
#URL_ASU=https://delivery04.dhe.ibm.com/sar/CMA/XSA/04sjw/0/ibm_utl_asu_asut86d-9.63_linux_i386.tgz
URL_ASU=https://delivery04.dhe.ibm.com/sar/CMA/XSA/04sjz/0/ibm_utl_asu_asut86d-9.63_linux_x86-64.tgz

# IPMI/IMM/iDRAC defaults
D_IMM_USER=USERID
D_IMM_PSWD=PASSW0RD
D_DRAC_USER=root
D_DRAC_PSWD=root

-include config.mk

all: $(FQDN)
	@echo 'What could be done, was done ...'

%: %.ipmi %.bios
	@echo 'Done'

test: util

clean:
	rm -f util/*

### Utils

define hprcu
	DEF=`mktemp` && \
	m4 -D_SERVER_NAME_=$2 $1 | tee $$DEF && \
	util/hprcu -a -l -f $$DEF && \
	unlink $$DEF
endef

define bmc_user_ipmitool
	bmc/user_ipmitool.sh $1 \
		-u $2 -p $3 \
		-U ${IPMI_USER} -P ${IPMI_PSWD}
endef

define asu
	util/asu64 batch $1 \
		--host $2 \
		--user ${IPMI_USER} \
		--password ${IPMI_PSWD}
endef

util/hprcu:
	mkdir -p util/
	curl "${URL_HPST}" | tar -C util/ --strip-components=2 \
		--occurrence=1 --no-anchored -xzvf - hprcu
	@echo "Download OK: $@"

util/asu64:
	mkdir -p util/
	curl "${URL_ASU}" | tar -C util/ \
		--occurrence=1 --no-anchored -xzv \
		asu64
	@echo "Download OK: $@"

util: util/hprcu util/asu64

### Machines

# fineus
fineus%.cerit-sc.cz.ipmi:
	@echo 'iLO setup TODO'
	@exit 1

fineus%.cerit-sc.cz.bios: util/hprcu
	@$(call hprcu,bios/fineus.cerit-sc.cz.xml,$@)


# hdb
hdb%.cerit-sc.cz.ipmi:
	@echo 'iLO setup TODO'
	@exit 1

hdb%.cerit-sc.cz.bios: util/hprcu
	@$(call hprcu,bios/hdb.cerit-sc.cz.xml,$@)


# hdc
hdc%.cerit-sc.cz.ipmi:
	@echo 'iLO setup TODO'
	@exit 1

hdc%.cerit-sc.cz.bios: util/hprcu
	@$(call hprcu,bios/hdc.cerit-sc.cz.xml,$@)


# zebra
zebra%.cerit-sc.cz.ipmi:
	$(call bmc_user_ipmitool,-h c-zebra$*a.priv.cerit-sc.cz,\
		${D_IMM_USER},${D_IMM_PSWD})
	$(call bmc_user_ipmitool,-h c-zebra$*b.priv.cerit-sc.cz,\
		${D_IMM_USER},${D_IMM_PSWD})

zebra%.cerit-sc.cz.bios: util/asu64
	$(call asu,bios/zebra.cerit-sc.cz.asu,c-zebra$*a.priv.cerit-sc.cz)
	$(call asu,bios/zebra.cerit-sc.cz.asu,c-zebra$*b.priv.cerit-sc.cz)


# zewura, requires obsolete 'conrep' tool
zewura%.cerit-sc.cz.ipmi:
	@echo 'iLO setup is manual process'
	@exit 1

zewura%.cerit-sc.cz.bios: bios/zewura.cerit-sc.cz.rbsu
	@echo 'BIOS setup is manual process, use BIOS RBSU'
	@exit 1
