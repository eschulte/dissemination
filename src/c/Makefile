CC:=gcc
CFLAGS:=-Wall -pedantic -Werror -Wundef -Winline -Wextra
BUILD=$(CC) $(CFLAGS) $(shell gpgme-config --cflags)
LINK=$(CC) $(CFLAGS) $(shell gpgme-config --libs)
SOURCES=sig.c
OBJECTS = $(SOURCES:.c=.o)
EXES = $(OBJECTS:.o=)

all: $(OBJECTS) $(EXES)
.PHONY: clean

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(shell gpgme-config --cflags)

%: %.o
	$(CC) -o $@ $< $(shell gpgme-config --libs)

debug:
	echo "$(OBJECTS) $(EXES)"

clean:
	rm -f $(OBJECTS) $(EXES)
