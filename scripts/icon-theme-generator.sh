#!/bin/bash
# icon-theme-generator.sh
# mauro@debian.org - 10/2012
# WTFPL.

# DEPENDENCIES:
# imagemagick - findutils - bash

BASE="scalable"
SIZES="8x8 16x16 22x22 24x24 32x32 48x48 64x64 128x128 256x256"

# gen_icons:
# a partir del directorio BASE genera en los diferentes SIZES
# al set de iconos utilizando `imagemagick`.

gen_icons(){
    shift;
    THEME=$1;
    [ -z "$THEME" ] && exit 1;

    for s in `echo $SIZES`;
    do    
        [ -d "$OUTDIR/$THEME/${s}/" ] || mkdir -p $OUTDIR/$THEME/$s;
        for ORIG in `find "./$THEME/${BASE}" -type f`;
        do
            ICON=`echo $ORIG|sed -e 's/\.\/scalable\///g'|cut -d '.' -f1`;
            ICON=`basename $ORIG|cut -d '.' -f1`;
            DESTDIR=`dirname $ORIG|sed -s 's/\.\/scalable\///g'`
            [ -d "$OUTDIR/$THEME/${s}/$DESTDIR" ] || mkdir -p \
                "$OUTDIR/$THEME/${s}/$DESTDIR";
            convert -background transparent -resize $s $ORIG $OUTDIR/$THEME/$s/$ICON.png
        done
    done


    cp -a ./$THEME/$BASE $OUTDIR/$THEME/$BASE
}

# gen_indextheme:
# en base al directorio donde estamos parados, deducimos al nombre del theme
# y luego generamos al index.theme con los directorios que se encuentren aqui.

gen_indextheme(){
    shift;
    THEMEDIR=$1;
    OUTDIR=$2;
    DESTDIR=$OUTDIR/$THEMEDIR

    TFL=`echo ${THEMEDIR:0:1}|tr [:lower:] [:upper:]`; 
    THEMENAME=`echo $TFL${THEMEDIR:1}|sed -s 's,\-, ,g'`;

    _DIRLIST=`find $THEMEDIR -type d|sed -s 's,\.\/,,g'|tr '\n' ','`;
    DIRLIST=${_DIRLIST:2}

    INDEXTHEME="[Icon Theme]\n";
    INDEXTHEME="${INDEXTHEME}Name=${THEMENAME}\n";
    INDEXTHEME="${INDEXTHEME}Comment=${THEMENAME} icon theme\n"
    INDEXTHEME="${INDEXTHEME}Directories=$DIRLIST\n"
    INDEXTHEME="${INDEXTHEME}"

    # imprimo al 'header'

    echo -e $INDEXTHEME

    # genero las secciones de los png

    for d in `find $DESTDIR -type d|grep -v 'scalable'|sed -s 's,\.\/,,g'`;
    do

        _dir=`echo $d|sed -s "s,$DESTDIR\/,,g"`;
        _section=`echo $dir|sed -s "s,$DESTDIR\/,,g"`;
        _size=`echo $dir|cut -d 'x' -f1`;
        _context=`echo $dir|cut -d '/' -f2`;

        if [ "$_context" != "$dir" ];then
            echo "[$_section]";
            echo "Size=$_size";
            echo "Context=$_context";
            echo "Type=Threshold";
            echo;
        fi

    done

    # genero las secciones de los svg

    for dir in `find $DESTDIR/scalable -type d|sed -s 's,\.\/,,g'`;
    do
        _section=`echo $dir|sed -s "s,$DESTDIR\/,,g"`;
        _context=`echo $dir|cut -d '/' -f2`;

        if [ "$_context" != "$dir" ];then
            echo "[$_section]";
            echo "MinSize=16";
            echo "Size=256";
            echo "MaxSize=256";
            echo "Context=$_context";
            echo "Type=Scalable";
            echo;
        fi

    done
}

# build:
# espero un nombre de theme/directorio-con-iconos-en-svg +
# directorio-destino y llamo a gen_icons y gen_indextheme.

build(){
    shift;
    THEME=$1;
    OUTDIR=$2;

    [ -z "$THEME" ] && exit 1;
    [ -z "$OUTDIR" ] && exit 1;
    [ -d "$OUTDIR" ] && mkdir -p $OUTDIR;

    # hack to allow the execution of the script
    # from the command line because of shifting
    # the first parameter always. and because
    # bash works in mysterious ways.
    # lol


    echo $THEME $OUTDIR

    gen_icons lol $THEME $OUTDIR;
    gen_indextheme lol $THEME $OUTDIR > $OUTDIR/$THEME/index.theme;

    echo $THEME $OUTDIR

    exit 0;
}

# clean:
# espero un nombre de theme/directorio-con-iconos-en-svg + 
# directorio-destino y borro a todos los png que esten ahi.

clean(){
    shift;
    OUTDIR=$1;

    [ -z "$OUTDIR" ] && exit 1;
    [ -d $OUTDIR ] && rm -fr $OUTDIR;

    exit 0;
}

# como leer:
# no tengo param y salgo o 'llamo' a $1 y con $@ como parametros.
#
# $1 = accion
# $@ = params

[ -z $1 ] && exit 0 || $1 $@;