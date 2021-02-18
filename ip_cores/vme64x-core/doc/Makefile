all: vme64x_core-ug.pdf

vme64x_core-ug.xml: vme64x_core-ug.txt
	asciidoc -v -d book -b docbook vme64x_core-ug.txt

vme64x_core-ug.pdf: vme64x_core-ug.xml
	a2x -f pdf vme64x_core-ug.xml

clean:
	$(RM) vme64x_core-ug.xml vme64x_core-ug.pdf
