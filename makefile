# {{{ -- meta

PUID       := $(shell id -u)
PGID       := $(shell id -g)# gid 100(users) usually pre exists
CURDIR     := $(shell pwd)
HOME       := $(shell echo $$HOME)


# IMAGETAG  := krismorte/hugo-docker
IMAGETAG  := bretfisher/jekyll-serve
CNTNAME   := jekyll # name for container name : docker_name, hostname : name

# -- }}}

# {{{ -- flags



CACHEFLAGS := --no-cache=true --pull
MOUNTFLAGS := -v $(PWD):/site 
PORTFLAGS  := -p 4000:4000 
# RUNFLAGS   := -c 256 -m 256m -e PGID=$(PGID) -e PUID=$(PUID) -u $(PUID):$(PGID)
# RUNFLAGS   += --sysctl net.ipv6.conf.all.disable_ipv6=1

NAMEFLAGS  := --name $(CNTNAME) --hostname $(CNTNAME)


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

THUMBS_DIR := gallery/thumb
LRGTHUMBS_DIR := gallery/small
PICS_DIR := gallery/medium
LRGPICS_DIR := gallery/large



filtered_pics: 
	processpictures.py  -jekyll -skip-newer-targets -overwrite -keep-original-name -dest $(FILTERED_DIR) -paths $(HOME)/Pictures/Social/*.jpg 
	# for fff in OriginalPics/*.md; do echo sed -i -e 's/\.jpg/\.webP/g' $$fff; done
	sed -i .bak 's/\.jpg/\.webP/g' OriginalPics/*.md
	mv -f OriginalPics/*.md _posts/
	

SRC_PICS := $(wildcard $(FILTERED_DIR)/*.jpg)
THUMBS := $(patsubst $(FILTERED_DIR)/%.jpg,$(THUMBS_DIR)/%.webP,$(SRC_PICS))
LARGETHUMBS := $(patsubst $(FILTERED_DIR)/%.jpg,$(LRGTHUMBS_DIR)/%.webP,$(SRC_PICS))
SMALLPICS := $(patsubst $(FILTERED_DIR)/%.jpg,$(PICS_DIR)/%.webP,$(SRC_PICS))
LARGEPICS := $(patsubst $(FILTERED_DIR)/%.jpg,$(LRGPICS_DIR)/%.webP,$(SRC_PICS))

MOGRIFY_CMD := mogrify -format webP -define webP:lossless=false



$(THUMBS_DIR)/%.webP: $(FILTERED_DIR)/%.jpg
	$(MOGRIFY_CMD) -quality 60 -path $(THUMBS_DIR) -thumbnail x110 $<

$(LRGTHUMBS_DIR)/%.webP: $(FILTERED_DIR)/%.jpg
	$(MOGRIFY_CMD) -quality 60 -path $(LRGTHUMBS_DIR) -thumbnail x250 $<

$(PICS_DIR)/%.webP: $(FILTERED_DIR)/%.jpg
	$(MOGRIFY_CMD) -quality 70 -path $(PICS_DIR) -resize 600 $<

$(LRGPICS_DIR)/%.webP: $(FILTERED_DIR)/%.jpg
	$(MOGRIFY_CMD) -quality 80 -path $(LRGPICS_DIR) -resize 1200 $<

gallery/%:
	mkdir -p $@

picdirs: $(THUMBS_DIR) $(LRGTHUMBS_DIR) $(PICS_DIR) $(LRGPICS_DIR)
	

pics: picdirs $(THUMBS) $(LARGETHUMBS) $(SMALLPICS) $(LARGEPICS)

	

build : 
	docker start -ai jekyll_builder || docker run -it --name jekyll_builder $(RUNFLAGS) $(MOUNTFLAGS) $(IMAGETAG) jekyll build --destination _build --trace

serve:
	docker start -ai jekyll_server || docker run -it --name jekyll_server $(RUNFLAGS) $(PORTFLAGS) $(MOUNTFLAGS) $(IMAGETAG)  

compress:
	find ./public/ -name '*.gz' -delete
	find ./public/ -type f -size +1k -regex  '.*\(html\|xml\|js\|css\)$$' -exec gzip -k -9 -f  \{\} \;

firebaseupload:
	firebase deploy --debug

upload: firebaseupload 

# -- }}}
