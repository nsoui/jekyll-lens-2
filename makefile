# {{{ -- meta

PUID       := $(shell id -u)
PGID       := $(shell id -g)# gid 100(users) usually pre exists
CURDIR     := $(shell pwd)
HOME       := $(shell echo $$HOME)


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
	echo deleting files below _posts and Original Pics
	rm -rf _posts/*
	rm -rf OriginalPics/*
	for fff in {thumbs,small,large}; do echo deleting files below $$fff; rm -rf gallery/$$fff/*; done 

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

# Picture handling

FILTERED_DIR := OriginalPics
THUMBS_DIR := gallery/thumbs
SMALL_DIR := gallery/small
LARGE_DIR := gallery/large



filtered_pics: 
	processpictures.py  -jekyll -skip-newer-targets -keep-original-name -dest $(FILTERED_DIR) -paths $(HOME)/Pictures/Social/*.jpg 
	mv -f OriginalPics/*.md _posts/

SRC_PICS := $(wildcard $(FILTERED_DIR)/*.jpg)
THUMBS := $(patsubst $(FILTERED_DIR)/%.jpg,$(THUMBS_DIR)/%.jpg,$(SRC_PICS))
SMALLPICS := $(patsubst $(FILTERED_DIR)/%.jpg,$(SMALL_DIR)/%.jpg,$(SRC_PICS))
LARGEPICS := $(patsubst $(FILTERED_DIR)/%.jpg,$(LARGE_DIR)/%.jpg,$(SRC_PICS))

MOGRIFY_CMD := mogrify  -format jpg -quality 100

$(THUMBS_DIR)/%.jpg: OriginalPics/%.jpg
	$(MOGRIFY_CMD) -path $(THUMBS_DIR) -thumbnail x250 $<

$(SMALL_DIR)/%.jpg: OriginalPics/%.jpg
	$(MOGRIFY_CMD) -path $(SMALL_DIR) -resize 600 $<

$(LARGE_DIR)/%.jpg: OriginalPics/%.jpg
	$(MOGRIFY_CMD) -path $(LARGE_DIR) -resize 1200 $<




pics: filtered_pics $(THUMBS) $(SMALLPICS) $(LARGEPICS)
	
	

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
