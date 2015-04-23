#!/usr/bin/perl -w

use Image::ExifTool;

use File::Basename;
use File::Path;
use File::Spec;
use File::Copy;
use File::Find;
use strict;

my $id = getlogin();

my $XP_SCANS_DIR = "XP_SCANS_DIR";
my $REL_PICTURES_STEP_1_DIR = "Pictures/MINOLTA/SCANS";
my @REL_PICTURES_STEP_1_DIR = File::Spec->splitdir($REL_PICTURES_STEP_1_DIR);

### SUB ###
	
sub set_file_image_extension {

    if ( -f $File::Find::name ) {
    	my ($sfile,$spath,$sext) = fileparse($File::Find::name, qr/\.[^.]*/);
    	my @spath = File::Spec->splitdir($spath);
		my $exifTool_object = new Image::ExifTool;
		my $info = $exifTool_object->ImageInfo($File::Find::name);
		my $MimeType = $exifTool_object->GetValue('MIMEType', 'ValueConv');
		
		if ( (defined $MimeType) && ($MimeType =~ /^(image)\/([^\/]+)/ )) {
			$sext = lc($2);
			print "EXT : ",$sext,"\n";
			splice( @spath,3,1,@REL_PICTURES_STEP_1_DIR );
			my $tfilename = File::Spec->catdir(@spath,$sfile).".".$sext;
			print "TAGET : ",$tfilename,"\n";
			if (! (-e File::Spec->catdir(@spath)) ) {
				mkpath(File::Spec->catdir(@spath));
			}	
			move($File::Find::name,$tfilename);	
    	}
    	else {
   			unlink $File::Find::name;	 
   		}
	}
}

### MAIN ###

my $ABS_XP_SCANS_DIR = File::Spec->catdir("/Users",$id,$XP_SCANS_DIR);

my $nextruntime = 0;
my $tempo = 10; # (10 secondes)

while(1){
   if ( time()>=$nextruntime ) {
   		finddepth(\&set_file_image_extension, $ABS_XP_SCANS_DIR );
      	$nextruntime=time()+$tempo;
   }
   sleep 1;
}

