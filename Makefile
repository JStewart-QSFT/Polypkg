PP_SHELL=	/bin/sh

PP_SRCS= \
	 pp.main \
	 pp.util \
	 pp.front \
	 pp.platform \
	 pp.expand \
	 pp.model \
	 pp.back \
         pp.back.aix \
         pp.back.sd \
	 pp.back.solaris \
	 pp.back.solaris.svc \
	 pp.back.rpm \
	 pp.back.rpm.svc \
	 pp.back.null

all: pp check
	cd example && $(MAKE)

pp: $(PP_SRCS)
	rm -f $@
	(echo '#!$(PP_SHELL)';                \
	 echo 'pp_revision="$(shell svnversion . | tr : _)"'; \
	 echo 'd=`dirname $$0`';          \
	 for p in $(PP_SRCS); do          \
	    echo '. "$$d/'$$p'" &&';        \
	 done;                            \
	 echo 'pp_main $${1+"$$@"}'       \
	) > $@
	chmod 555 $@

pp-stripped: $(PP_SRCS)
	(echo '#!$(PP_SHELL)';                \
	 echo '# (c) 2006 Quest Software, Inc. All rights reserved'; \
	 echo 'pp_revision="$(shell svnversion . | tr : _)"'; \
	 cat pp.licence; \
	 sed -e '/^#/d' $(PP_SRCS);	\
	 echo 'pp_main $${1+"$$@"}';	\
	 ) > $@
	chmod +x $@

clean:
	rm -f pp pp-stripped tags
	cd example && $(MAKE) clean

TEST_SHELL=sh

check: pp
	@ex=0; for t in tests/t-*; do \
	    ${TEST_SHELL} -f tests/driver $$t || ex=1; \
	done; exit $$ex

tags: $(PP_SRCS)
	for f in $(PP_SRCS); do \
	    : sed -n -e 's,^\(#@[ 	]*\$$*\([^(:/ ]*\)[^:]*:*\).*,\2	'$$f'	/^\1/,p' $$f; \
	    sed -n -e 's,^\(\([a-zA-Z_][a-zA-Z_0-9]*\)[ 	]*(\))[ 	]*{.*,\2	'$$f'	/^\1/,p' \
		-e 's,^\(\([a-zA-Z_][a-zA-Z_0-9]*\)=\).*,\2	'$$f'	/^\1/,p' $$f; \
	done |sort > $@

install: pp-stripped
	cp -f pp-stripped /data/rc/pub/rc/polypkg/pp
