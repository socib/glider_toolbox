DOCDIR := doc
#MFILES := $(wildcard m/*.m m/*_tools)
MFILES := m
IGNORE := private @sftp
M := matlab

ifeq ($(M), matlab)
MFLAGS := -nodisplay -r
else ifeq ($(M), octave)
MFLAGS := --eval
else
$(error unknown interpreter '$(M)' (should be 'matlab' or 'octave'))
endif

all: doc

doc:
	-mkdir -p doc
	rm -rf doc/*
	$(M) $(MFLAGS) \
	  "m2html('mfiles', {$(addprefix ',$(addsuffix ',$(MFILES)))}, \
	          'ignore', {$(addprefix ',$(addsuffix ',$(IGNORE)))}, \
	          'recursive', 'on', 'global', 'on', \
	          'graph', 'on', 'search', 'on', 'download', 'on', \
	          'template', 'frame', 'index', 'menu', 'htmldir', '$(DOCDIR)')" \
	  < /dev/null

graph:
	echo "Generating graph from notes/graph.dot (be sure that it is up to date)."
	dot -Tsvg -o notes/graph.svg -T cmap -o notes/graph.map -Gsize="8,8" notes/graph.dot
	sed -i -n '1h;1!H;$${g;s#<map name="mainmapdt">.*</map>#<map name="mainmapdt">\n</map>#g;p;}' notes/graph.html
	sed -i '/<map name="mainmapdt">/r notes/graph.map' notes/graph.html

.PHONY: all doc graph
