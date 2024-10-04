libtotp: libtotp.c
	gcc -o libtotp.so libtotp.c -lcotp -llua5.1 -Wall -Werror -fpic -shared

PREFIX = /usr/local

install: libtotp.so
	install -d $(DESTDIR)$(PREFIX)/lib/
	install -m 644 libtotp.so $(DESTDIR)$(PREFIX)/lib/lua/5.1/