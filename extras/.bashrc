# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PS1="[ \u@\h \W \$(__git_ps1 '(%s)') ]\$ "

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

export MONKEYMAN_DIR="${HOME}/monkeyman"
export MONKEYMAN_DUMP_DIR="${MONKEYMAN_DIR}/var/dump"

export PERL5LIB="${MONKEYMAN_DIR}/lib"

function monkeyman_find_dump {

	local FOUND
	local TARGET

	local OBJECT_ID="${1}"
	if [ -z "${OBJECT_ID}" ]; then
		echo "The object ID hasn't been defined" >&2
		return 1
	fi

	local PID="${2}"
	if [ -z "${PID}" ]; then
		TARGET="*/${OBJECT_ID}"
	else
		TARGET="*/${PID}/${OBJECT_ID}"
	fi

	FOUND=$(find "${MONKEYMAN_DUMP_DIR}" -path "${TARGET}" -printf "%C@\t%p\n" | sort -rn | head -n 1 | cut -f 2)
	if [ "${?}" -ne 0 ] || [ -z "${FOUND}" ]; then
		echo "Can't find the object by criterias" >&2
		return 1
	fi

	echo "${FOUND}"

}

function monkeyman_dump {

	local FILE
	FILE=$(monkeyman_find_dump $@)
	if [ -r "${FILE}" ]; then
		echo "Dumping ${FILE}:"
		cat "${FILE}"
	else
		echo "Can't find the dump of ${@}"
		return 1
	fi

}

# function monkeyman_pods2mds {
# 
# 	local POD_DIRNAME="${1}"
# 	if [ -z "${POD_DIRNAME}" ]; then
# 		POD_DIRNAME="${HOME}/monkeyman"
# 	fi
# 	local DOC_DIRNAME="${2}"
# 	if [ -z "${DOC_DIRNAME}" ]; then
# 		DOC_DIRNAME="${HOME}/monkeyman/doc"
# 	fi
# 	local PERL_SCRIPT_DIR="${HOME}/tmp"
# 
# 	for FILENAME in $(find ${POD_DIRNAME} -name '*.p[lm]' ); do
# 		local FILENAME_SHORT=$(basename "${FILENAME}")
# 		local FILENAME_SHORT_NEW="${FILENAME_SHORT}.md"
# 		local DIRNAME_NEW=$(echo "${FILENAME}" |
# 			sed -n "s#^\(${POD_DIRNAME}/\)\(.\+\)\?/${FILENAME_SHORT}\$#${DOC_DIRNAME}/\2#gp")
# 		local FILENAME_NEW="${DIRNAME_NEW}/${FILENAME_SHORT_NEW}"
# 		if [ "${FILENAME_NEW}" -ot "${FILENAME}" ]; then
# 			if [ ! -x "${PERL_SCRIPT}" ]; then
# 				PERL_SCRIPT=$(mktemp --tmpdir=${PERL_SCRIPT_DIR} XXXXXXXX.pl)
# 				cat <<__END_OF_SCRIPT__ >"${PERL_SCRIPT}"
# #!/usr/bin/env perl
# 
# use strict;
# use warnings;
# use autodie qw(open close);
# 
# use Getopt::Long;
# use Pod::Markdown::Github;
# 
# my \$filename;
# GetOptions('filename|f=s' => \\\$filename);
# die("The filename isn't defined")
#     unless(defined(\$filename));
# 
# my \$markdown = Pod::Markdown::Github->new(
#     perldoc_url_prefix => 'https://github.com/melnik13/monkeyman/tree/dev_melnik13_v3/doc/lib/'
# );
# \$markdown->output_fh(*STDOUT);
# \$markdown->parse_file(\$filename);
# __END_OF_SCRIPT__
# 				chmod u+x "${PERL_SCRIPT}"
# 			fi
# 			local MD=$(${PERL_SCRIPT} -f "${FILENAME}")
# 			if [ $(echo "${MD}" | wc -l) -gt 1 ]; then
# 				if [ ! -d "${DIRNAME_NEW}" ]; then
# 					mkdir -p "${DIRNAME_NEW}"
# 				fi
# 				echo "${FILENAME} -> ${FILENAME_NEW}"
# 				echo "${MD}" > "${FILENAME_NEW}"
# 			fi
# 		fi
# 	done
# 	if [ -r "${PERL_SCRIPT}" ]; then
# 		rm -f "${PERL_SCRIPT}"
# 	fi
# 
# }
