#*****************************VISUALS*******************************#

BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
PURPLE       := $(shell tput -Txterm setaf 5)
BLUE         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)

RESET 		 := $(shell tput -Txterm sgr0)

MSG_OK		= ${GREEN}[OK]${RESET}
MSG_KO		= ${RED}[KO]${RESET}

MSG_COMPILE	= ${YELLOW}Compiled${RESET}
MSG_LIB		= ${YELLOW}Lib${RESET}
MSG_RUN		= ${YELLOW}Run${RESET}

MSG_CLEAN	= ${YELLOW}clean${RESET}
MSG_FCLEAN	= ${YELLOW}fclean${RESET}
MSG_RE		= ${YELLOW}re${RESET}

MSG_HEADER	= ${YELLOW}Header del${RESET}
MSG_A		= ${YELLOW}*.a Del${RESET}
MSG_O		= ${YELLOW}*.o Del${RESET}
MSG_PROG	= ${YELLOW}Prog del${RESET}

MSG_VERS_DEL= ${YELLOW}latest version del${RESET}
MSG_VERS_ADD= ${YELLOW}new version added${RESET}
MSG_VERS_REV= ${YELLOW}version reverted${RESET}

#***************************FUNCTIONS*******************************#

define echo_status
	(echo "$(MSG_OK) $(1)"; exit 0) || (echo "$(MSG_KO) $(1)"; exit 84);
endef

define echo_time
	(echo "${YELLOW}Last version is${BLUE}$(1)${RESET}");
endef

define change_val
	sed -i "/^$(1).*/c $(1)\t$(2).tar.gz" Makefile;
endef

define tar_this
	$(TAR) --exclude=./$(1)/* $(ZIP_FLAG) $(1)/$(2) ./*;
endef

define untar_this
	$(TAR) $(UNZIP_FLAG) $(1)/$(2) -C ./;
endef

#***************************VARIABLES*******************************#

NAME	=

SRC		=

OBJ		=	$(SRC:.c=.o)

CFLAGS	=	-Werror -Wextra -Wall -I include/

LIB_A	=	my_lib
LIB_DIR	=	lib/
LIB		=	-l $(LIB_A) -L $(LIB_DIR)

VERS_DIR=   versions
VERS_NAME:=	2020-08-05T16:04:16+02:00.tar.gz

TAR     =   tar
ZIP_FLAG=   -cvf
UNZIP_FLAG= -xvf

TIME_STAMP=	$(shell date --iso=seconds)

#******************************ALL**********************************#

.PHONY : all
all :		$(NAME)

#****************************COMPIL*********************************#

.PHONY : compil_lib
compil_lib :
			@make -C lib/my_lib/\
				&& $(call echo_status, $(MSG_LIB))

$(NAME) :
			@$(CC) $(SRC) -o $(NAME) $(CFLAGS)\
				&& $(call echo_status, $(MSG_COMPILE))

#************************TESTING & DEBUGGING************************#

.PHONY : criter
criter :	CFLAGS += -lcriterion --coverage
criter :	run

.PHONY : recriter
recriter :	fclean criter

.PHONY : run
run :		$(NAME)
			@./$(NAME)\
				&& $(call echo_status, $(MSG_RUN))

.PHONY : rerun
rerun :		fclean run

.PHONY : debug
debug :		CFLAGS += -g3
debug :		fclean $(NAME)

#***************************VERSIONNING*****************************#

.PHONY : version_add
version_add :
			@mkdir -p $(VERS_DIR)\
				&& $(call change_val,"VERS_NAME:=",$(TIME_STAMP))\
				$(call tar_this,$(VERS_DIR),"$(TIME_STAMP).tar.gz")\
				$(call echo_status, $(MSG_VERS_ADD))

.PHONY : version_del
version_del :
			@rm $(VERS_DIR)/$(VERS_NAME)\
				&& $(call echo_status, $(MSG_VERS_DEL))

.PHONY : version_rev
version_rev :
			@$(call untar_this,$(VERS_DIR),$(VERS_NAME))\
			$(call echo_status, $(MSG_VERS_REV))

.PHONY : verion_info
version_info :
			@$(call echo_time, $(VERS_NAME))

#*****************************CLEANING******************************#

.PHONY : clean
clean :
			@$(RM) $(OBJ)\
				&& $(call echo_status, $(MSG_CLEAN))

.PHONY : fclean
fclean : 	clean
			@$(RM) $(NAME)\
				&& $(call echo_status, $(MSG_FCLEAN))

.PHONY : re
re :		fclean all
				@$(call echo_status, $(MSG_RE))