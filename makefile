# {{{ -- meta

PUID       := $(shell id -u)
PGID       := $(shell id -g)# gid 100(users) usually pre exists
CURDIR     := $(shell pwd)


# IMAGETAG  := krismorte/hugo-docker
IMAGETAG  := jekyll/jekyll
CNTNAME   := jekyll # name for container name : docker_name, hostname : name

# -- }}}

# {{{ -- flags



CACHEFLAGS := --no-cache=true --pull
MOUNTFLAGS := -v $(PWD):/srv/jekyll:Z --volume=$(PWD)/vendor/bundle:/usr/local/bundle:Z 
PORTFLAGS  := -p 4000:4000 
# RUNFLAGS   := -c 256 -m 256m -e PGID=$(PGID) -e PUID=$(PUID) -u $(PUID):$(PGID)
# RUNFLAGS   += --sysctl net.ipv6.conf.all.disable_ipv6=1

NAMEFLAGS  := --name $(CNTNAME) --hostname $(CNTNAME)

# -- }}}

# {{{ -- docker targets

HUGO_ENV:= HUGO_NUMWORKERMULTIPLIER=1

all : build compress upload

logs :
	docker logs -f $(CNTNAME)

pull :
	docker pull $(IMAGETAG)

run:
	docker run -it --rm $(NAMEFLAGS) $(RUNFLAGS) $(PORTFLAGS) $(MOUNTFLAGS) $(IMAGETAG)

distclean: clean
	rm -rf resources/_gen/*

clean:
	rm -rf public/*

rebuild: distclean build

HUGO_CMD := docker run -it --rm $(NAMEFLAGS) $(RUNFLAGS) $(PORTFLAGS) $(MOUNTFLAGS) $(IMAGETAG)

shell:
	$(HUGO_CMD) shell

install:
	$(HUGO_CMD) bundle install

thumb_height := 250
thumb_quality := 75
small_width := 600
full_width := 1200
full_height := 900
    

pics:
	mogrify  -format jpg -path gallery/thumbs -thumbnail x250 OriginalPics/*.jpg
	mogrify  -format jpg -path gallery/small -resize 600x OriginalPics/*.jpg
	mogrify  -format jpg -path gallery/large -resize 600x OriginalPics/*.jpg

build : 
	$(HUGO_CMD) jekyll build

serve:
	$(HUGO_CMD) jekyll serve --trace

compress:
	find ./public/ -name '*.gz' -delete
	find ./public/ -type f -size +1k -regex  '.*\(html\|xml\|js\|css\)$$' -exec gzip -k -9 -f  \{\} \;

firebaseupload:
	firebase deploy --debug

upload: firebaseupload 

# -- }}}
