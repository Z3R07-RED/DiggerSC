#!/bin/bash
#DiggerSC
#Coded by Z3R07-RED on Mar 18 2021
#
#VARIABLES:
termux_path="/data/data/com.termux/files/usr/bin"
kali_linux_path="/usr/bin"
DISKDIGGER="DiskDigger"
INSPECTDIR="$HOME/"
SAVETODIR="$(pwd)/"
DIALOG=${DIALOG=dialog}
dialogrc_file=".config/RedPower.conf"
ATYPE01="on"
ATYPE02="off"
ATYPE03="off"
ATYPE04="off"
ATYPE05="off"
ATYPE06="off"
DGGROPT01="off"
DGGROPT02="off"
DGGROPT03="off"
DGGROPT04="off"

#colors dialog
if [[ -f "$dialogrc_file" ]]; then
    export DIALOGRC=$dialogrc_file
fi
#universal_functions && universal_variables
if [[ -f "CS07/universal_functions" && -f "CS07/universal_variables" ]]; then
    source "CS07/universal_functions"
    source "CS07/universal_variables"
else
    echo -e "[ERROR]: \"universal_functions\" \"universal_variables\""
    echo "";exit 0
fi
#colors
if [[ -f "$colors" ]]; then
    source "$colors"
else
    file_not_found "colors"
fi

# Directory
if [[ ! -d "$log_directory" ]]; then
	mkdir $log_directory
fi

# Directory
if [[ ! -d "$tmp_directory" ]]; then
	mkdir "$tmp_directory"
fi

#CTRL+C
trap ctrl_c INT

function ctrl_c(){
echo $(clear)
rm -rf tmp/* 2>/dev/null
rm -rf logs/* 2>/dev/null
echo "Program aborted."
tput cnorm 2>/dev/null
echo "";exit 1
}

#FUNCTIONS:
function ncurses_utils(){
if [ ! "$(command -v tput)" ]; then
	echo -e "\n${Y}[I]${W} apt install ncurses-utils ...${W}"
	apt install ncurses-utils -y > /dev/null 2>&1
	sleep 1
fi
}

# dependencies
function dependencies(){
if [[ -d "$kali_linux_path" ]]; then
   ZEROAPT="apt-get"
else
    ZEROAPT="apt"
	ncurses_utils
fi

tput civis; counter_dn=0
echo $(clear);sleep 0.3

dependencies=(dialog file zip) # dependencies
for program in "${dependencies[@]}"; do
    if [ ! "$(command -v $program)" ]; then
        echo -e "\n${R}[X]${W}${C} $program${Y} is not installed.${W}"
        sleep 0.8
        echo -e "\n\e[1;33m[i]\e[0m${C} Installing ...${W}"
        $ZEROAPT install $program -y > /dev/null 2>&1
        echo -e "\n\e[1;32m[V]\e[0m${C} $program${Y} installed.${W}"
        sleep 1
        let counter_dn+=1
    fi
done

$DIALOG --backtitle "Community - Club Secreto 07" \
     --colors --title "$program_name - v$version" \
     --infobox "\n\Zu$program_name (c) $(echo "$making" |awk 'NF{print $NF}' 2>/dev/null) by $author\Zn\n\nThis program comes ABSOLUTELY WITHOUT WARRANTY;\nthanks for using the program." 10 60 ;sleep 5

tput cnorm
}

# SETTING
function digger_settings(){
DGSETTINGS=$($DIALOG --stdout --cancel-label "Back" --ok-label "Apply" \
                     --backtitle "DiggerSC - v$version" \
					 --item-help --title "SETTING" \
					 --default-item "Progress" --checklist "" 10 60 4 \
				     "Delete"   "[Delete original files]" $DGGROPT01 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
					 "Progress" "[Show progress        ]" $DGGROPT02 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
					 "Verbose"  "[Create verbose file  ]" $DGGROPT03 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
				     "Compress" "[Save compressed      ]" $DGGROPT04 "[↑↓]-Move [SPACE]-Select [ESC]-Exit")

case $? in
	0)
		if [[ -d "$tmp_directory" ]]; then
			for dggml in ${DGSETTINGS[@]};
			do
				if [[ "$dggml" == "Delete" ]]; then
					DGGROPT01="Delete"
				elif [[ "$dggml" == "Progress" ]]; then
					DGGROPT02="Progress"
				elif [[ "$dggml" == "Verbose" ]]; then
					DGGROPT03="Verbose"
				elif [[ "$dggml" == "Compress" ]]; then
					DGGROPT04="Compress"
				fi
			done

			if [[ "$DGGROPT01" == "Delete" ]]; then
				DGGROPT01="on"
			else
				DGGROPT01="off"
			fi

			if [[ "$DGGROPT02" == "Progress" ]]; then
				DGGROPT02="on"
			else
				DGGROPT02="off"
			fi

		    if [[ "$DGGROPT03" == "Verbose" ]]; then
				DGGROPT03="on"
			else
				DGGROPT03="off"
			fi

			if [[ "$DGGROPT04" == "Compress" ]]; then
				DGGROPT04="on"
			else
				DGGROPT04="off"
			fi

			echo "$DGSETTINGS" > "$tmp_directory/diggersc_config.tmp"
			$DIALOG --backtitle "$program_name - v$version" --title "SETTING" \
				    --infobox "\nSuccessful configuration! :)" 8 45 ;sleep 3
		else
			tput cnorm
			unexpected_error
		fi
		;;
	255)
		tput cnorm; echo $(clear)
		echo "Program aborted." >&2
		echo ""; exit 0
		;;
esac
}

# START DIGGER
function start_digger(){
tput civis
$DIALOG --backtitle "$program_name - v$version" \
	    --title "DiggerSC" \
		--ok-label "Exit" \
		--prgbox "bash $DISKDIGGER" 15 60

tput cnorm; echo $(clear)
echo "Exiting ..."
echo ""
exit 0
}

# DIRECTORIES
function enter_directories(){
SDIR=$($DIALOG --stdout --ok-label "Start" --cancel-label "Back" \
                --backtitle "$program_name - v$version" \
                --title "DIRECTORIES" --colors \
                --form "Para comenzar, presione la tecla '\Zb\Z4\ZuTAB\Zn' y\nluego '\Zb\Z4\ZuEnter\Zn'" 15 60 6 \
                "¿Dónde busco los archivos?" 1 2 "$INSPECTDIR" 2 2 45 50000 \
                "¿Dónde guardo los archivos encontrados?" 4 2 "$SAVETODIR" 5 2 45 50000 )

case $? in
    0)
        if [[ -n "$SDIR" ]]; then
            echo "$SDIR" > "$tmp_directory/inspect_directory.txt"
            let nupathlist=$(grep . "$tmp_directory/inspect_directory.txt" |wc -l)
            if [[ "$nupathlist" == 2 ]]; then
                INSPECTDIR=$(awk "NR==1" "$tmp_directory/inspect_directory.txt" 2>/dev/null)
                SAVETODIR=$(awk "NR==2" "$tmp_directory/inspect_directory.txt" 2>/dev/null)

                if [[ ! -d "$INSPECTDIR" ]]; then
                    BASEINSPECTDIR=$(basename "$INSPECTDIR" 2>/dev/null)
                    file_not_found "$BASEINSPECTDIR"

                elif [[ ! -d "$SAVETODIR" ]]; then
					if [[ -n "$SAVETODIR" ]]; then
						if [[ ! -e "$SAVETODIR" && ! -L "$SAVETODIR" && ! -f "$SAVETODIR" ]]; then
							$DIALOG --colors --backtitle "$program_name" --title "DIRECTORY" --clear \
								    --yesno "'\Zb\Z4\Zu$SAVETODIR\Zn' is not a directory. Do you want to create it?" 8 61

							case $? in
								  0)
									  mkdir -p "$SAVETODIR" 2>/dev/null
									  ;;
								  1)
									  SAVETODIR=""
									  ;;
								  255)
									  echo $(clear)
									  echo "Program aborted." >&2
									  echo "";exit 1
									  ;;
							  esac
						  else
							  unexpected_error
						fi
					else
						unexpected_error
					fi
				fi

				if [[ -n "$SAVETODIR" ]]; then
					if [[ -x "$DISKDIGGER" ]]; then
						start_digger
				    elif [[ -f "$DISKDIGGER" ]]; then
					    chmod +x "$DISKDIGGER"
						start_digger
				    else
					    file_not_found "$DISKDIGGER"
					fi
				fi
			else
				unexpected_error
			fi
		else
			unexpected_error
		fi
        ;;

    255)
        echo $(clear)
        echo "Program aborted." >&2
        echo ""; exit 1
        ;;
esac
}

#MAIN MENU
function diggerscmenu(){
while :
do
tput civis
inspector_menu_opt=$($DIALOG --stdout --backtitle "$program_name - v$version" \
                 --item-help --title "TYPE OF FILES" \
                 --extra-button --extra-label "Settings" --cancel-label "Exit" \
                 --default-item 2 --checklist "Busca incluso los archivos más ocultos y protegidos en los directorios.\nPresione la tecla 'SPACE'" 12 60 4 \
                 1 "Imagenes [Buscar Imágenes ]" $ATYPE01 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
                 2 "Videos   [Buscar Videos   ]" $ATYPE02 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
			     3 "Audios   [Buscar Audios   ]" $ATYPE03 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
			     4 "PDF      [Buscar PDF      ]" $ATYPE04 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
			     5 "Texto    [Buscar txt      ]" $ATYPE05 "[↑↓]-Move [SPACE]-Select [ESC]-Exit" \
			     6 "ZIP/TAR  [Buscar zip/tgz  ]" $ATYPE06 "[↑↓]-Move [SPACE]-Select [ESC]-Exit")

case $? in
    0)
		tput cnorm
        if [[ -n "$inspector_menu_opt" ]]; then
            echo "$inspector_menu_opt" > "$tmp_directory/file_types.tmp"
            enter_directories
        else
            unexpected_error
        fi
        ;;
    1)
        tput cnorm; echo $(clear)
        echo -e "${G}Exiting the program ...${W}"
        echo ""; exit 0
        ;;
	3)
		if [[ -n "$inspector_menu_opt" ]]; then
			for DMOPT in ${inspector_menu_opt[@]};
		    do
				if [[ "$DMOPT" == 1 ]]; then
					ATYPE01="1"
			    elif [[ "$DMOPT" == 2 ]]; then
				    ATYPE02="2"
			    elif [[ "$DMOPT" == 3 ]]; then
				    ATYPE03="3"
			    elif [[ "$DMOPT" == 4 ]]; then
				    ATYPE04="4"
			    elif [[ "$DMOPT" == 5 ]]; then
				    ATYPE05="5"
			    elif [[ "$DMOPT" == 6 ]]; then
				    ATYPE06="6"
			    fi
		    done

			if [[ "$ATYPE01" == 1 ]]; then
				ATYPE01="on"
			else
				ATYPE01="off"
			fi

			if [[ "$ATYPE02" == 2 ]]; then
				ATYPE02="on"
			else
				ATYPE02="off"
			fi

			if [[ "$ATYPE03" == 3 ]]; then
				ATYPE03="on"
			else
				ATYPE03="off"
			fi

			if [[ "$ATYPE04" == 4 ]]; then
				ATYPE04="on"
			else
				ATYPE04="off"
			fi

			if [[ "$ATYPE05" == 5 ]]; then
				ATYPE05="on"
			else
				ATYPE05="off"
			fi

			if [[ "$ATYPE06" == 6 ]]; then
				ATYPE06="on"
			else
				ATYPE06="off"
			fi
		fi
		digger_settings
		;;
    255)
        tput cnorm; echo $(clear)
		rm -rf "$tmp_directory/*" 2>/dev/null
        echo "Program aborted." >&2
        echo ""; exit 0
        ;;
esac
done
}

dependencies
diggerscmenu


