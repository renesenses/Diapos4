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


sub from_VM_to_SCAN_DIR {
	my @t_dir;
	my $t_dir;
	if ( !($_ =~ /^\./) ) {
		if ( -d $File::Find::name ) { 
			@t_dir = File::Spec->splitdir($File::Find::name);
			splice( @t_dir,3,1,@REL_PICTURES_STEP_1_DIR );
			$t_dir = File::Spec->catdir(@t_dir);
			if ( !(-e  $t_dir) ) {
				mkpath($t_dir);
			}	
    	}	
    	else {  

    		my ($s_file,$s_path,$s_ext) = fileparse($File::Find::name, qr/\.[^.]*/);
    
			my $exifTool_object = new Image::ExifTool;
			my $info = $exifTool_object->ImageInfo($File::Find::name);
			my $MimeType = $exifTool_object->GetValue('MIMEType', 'ValueConv');
			
			# If is an image
			if ( (defined $MimeType) && ($MimeType =~ /^(image)\/([^\/]+)/) ) {
				my $t_ext = lc($2);			
				@t_dir = File::Spec->splitdir($File::Find::dir);
				splice( @t_dir,3,1,@REL_PICTURES_STEP_1_DIR );
				$t_dir = File::Spec->catdir(@t_dir);
				my $t_filename = File::Spec->catfile($t_dir,$s_file) . "." . $t_ext;
				print "move '$File::Find::name', '$t_filename' \n";
				move($File::Find::name,$t_filename);			
    		}
    		else {
    			print "rm '$File::Find::name' \n";
	   			unlink $File::Find::name;	 
   			}
		}
	}
}

### MAIN ###



my $ABS_XP_SCANS_DIR = File::Spec->catdir("/Users",$id,$XP_SCANS_DIR);

my $nextruntime = 0;
my $tempo = 10; # (10 secondes)

while(1){
   if ( time()>=$nextruntime ) {
   		find(\&from_VM_to_SCAN_DIR, $ABS_XP_SCANS_DIR );
      	$nextruntime=time()+$tempo;
   }
   sleep 1;
}

