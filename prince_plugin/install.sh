#! /bin/sh

PRODUCT="Prince"
PROGRAM="prince"
VERSION="7.0"
WEBSITE="http://www.princexml.com"

prefix=/usr/local

base=`dirname $0`

cd "$base"

echo "$PRODUCT $VERSION"
echo
echo "Install directory"
echo "    This is the directory in which $PRODUCT $VERSION will be installed."
echo "    Press Enter to accept the default directory or enter an alternative."
echo -n "    [$prefix]: "

read input
if [ ! -z "$input" ] ; then
    prefix="$input"
fi

echo
echo "Installing $PRODUCT $VERSION..."

# Create shell script

cat > prince <<EOF
#! /bin/sh

exec $prefix/lib/$PROGRAM/bin/$PROGRAM --prefix="$prefix/lib/$PROGRAM" "\$@"
EOF

# Test that we can create directories

install -d "$prefix/bin" 2>/dev/null ||
{
echo "    Unable to create directories in $prefix"
echo "    (You may need to be logged in as root to install programs in system"
echo "    directories. Ask your system administrator, or try installing inside"
echo "    your home directory, such as $HOME/$PROGRAM-$VERSION)."
echo
exit 1
}

# Install shell script

install prince "$prefix/bin"

# Install everything else

echo "Creating directories..."

for dir in `find lib/$PROGRAM -type d` ; do

    install -d "$prefix/$dir"

done

echo "Installing files..."

for file in `find lib/$PROGRAM -type f` ; do

    dir=`dirname $file`

    if [ -x "$file" ] ; then
	install "$file" "$prefix/$dir"
    else
	if [ "$file" = "lib/$PROGRAM/license/license.dat" ] ; then
	    if [ ! -f "$prefix/$file" ] ; then
		install -m 644 "$file" "$prefix/$dir"
	    fi
	else
	    install -m 644 "$file" "$prefix/$dir"
	fi
    fi

done

echo
echo "Installation complete."
echo "    Thank you for choosing $PRODUCT $VERSION, we hope you find it useful."
echo "    Please visit $WEBSITE for updates and development news."
echo

