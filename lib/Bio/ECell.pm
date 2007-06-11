package Bio::ECell;

use 5.006;
use strict;
use warnings;

BEGIN{
    my @lines = qx|ecell3-python -h|;

    if ($?){
	print STDERR "E-Cell3 is not installed on your system. Bio::ECell will not work.\n";
    }else{

	my $flag = 0;
	foreach my $line (@lines){
	    chomp($line);
	    
	    $flag = 1 if($line =~ /^Configurations:/);
	    if($flag == 1 && $line =~ /^\s+(\S+)\s+\=\s+(.*)/){
		$ENV{$1} .= ':' if ($ENV{$1});
		$ENV{$1} .= $2;
	    }
	}   

	$ENV{ECELL3_DM_PATH} .= ':' . $ENV{prefix} . '/lib/' . $ENV{PACKAGE} . '/' . $ENV{VERSION}; 
	$ENV{ECELL3_PREFIX} = $ENV{prefix};
	$ENV{OSOGOPATH} = $ENV{prefix} . '/lib/osogo';
	$ENV{MEPATH} = $ENV{prefix} . '/lib/modeleditor';
	$ENV{TLPATH} = $ENV{prefix} . '/lib/toollauncher';
	$ENV{PYTHONDIR} = $ENV{pythondir};
	$ENV{LTDL_LIBRARY_PATH} .= ':.:/sw/lib/ecell-3.1/dms/' . $ENV{ECELL3_DM_PATH} . ':' . $ENV{prefix} . '/lib/ecell/' . $ENV{VERSION};

	require Inline;
	import Inline Python => << '__INLINE_PYTHON__';
import sys
import string
import getopt
import os

import ecell
import ecell.ecs
import ecell.emc
import ecell.Session

from ecell.ECDDataFile import *

def internalLoadEcell3():
    aSimulator = ecell.emc.Simulator()
    aSession = ecell.Session(aSimulator)
    return aSession

def internalECDDataFile(logger):
    return ECDDataFile(logger.getData())

__INLINE_PYTHON__


    }
}


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Bio::ECell ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.02';


sub new{
    my $pkg = shift;
    my $this = internalLoadEcell3();

    return $this;
}

sub ECDDataFile{
    my $this = shift;
    my $logger = shift;

    return internalECDDataFile($logger);
}

=head1 NAME

Bio::ECell - Perl interface for E-Cell Simulation Environment.

=head1 SYNOPSIS

    use Bio::ECell;

    my $ecell = Bio::ECell::new();

    $ecell->loadModel("simple.eml");
    $ecell->message("Message from Perl!");

    my $logger = $ecell->createLoggerStub('Variable:/:S:Value');
    $logger->create();

    print $ecell->getCurrentTime(), "\n";
    $ecell->run(100);
    print $ecell->getCurrentTime(), "\n";

    my $data = Bio::ECell->ECDDataFile($logger );
    $data->setDataName( $logger->getName() );
    $data->save('S.ecd');

=head1 DESCRIPTION

Bio::ECell is a Perl interface for the E-Cell Simulation Environment 
version 3 (http://www.e-cell.org/), a generic cell simulation software 
for molecular cell biology researches that allow object-oriented modeling 
and simulation, multi-algorithm/time-scale simulation, and scripting 
through Python. This module allows scripting of sessions with Perl. 

For the details of the E-Cell API, users should refer to the chapter
about scripting a simulation session of E-Cell3 Users Manual, available
at the above-mentioned web-site.

=head2 new

The constructor is just a wrapper around the instance given by 

    ecell.Session(ecell.emc.Simulator())

in Python.

Basically functions required for scripting can be called from this instance.

=head2 ECDDataFile

ECDDataFile constructor can be called as follows:

    $ecell = Bio::ECell::new();
    $logger = $ecell->createLoggerStub('Path-name-for-logger');
    $logger->create();
    $data = Bio::ECell->ECDDataFile( $logger );

Here usage is slightly different from the Python interface, passing
the logger instance instead of the DATA tuple. Internally the system
calls logger.getData() to pass onto ECDDataFile.

=head1 SEE ALSO

For complete descriptions of E-Cell API, see
http://www.e-cell.org/software/documentation/ecell3-users-manual_0606.pdf

=head1 AUTHOR

Kazuharu Arakawa, E<lt>gaou@sfc.keio.ac.jpE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kazuharu Arakawa

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut



1;
__END__
