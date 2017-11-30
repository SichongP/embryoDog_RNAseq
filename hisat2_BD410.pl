#!/usr/bin/perl
#system(module load hisat);
my $r1, $r2;
open(my $r1file,"R1.txt") or die "Can't open R1.txt";
open(my $r2file,"R2.txt") or die "Can't open R2.txt";
#print $r2file;
#$r1=<$r1file>; print $r1;
$r1=<$r1file>;$r2=<$r2file>;
my $BD342_1,$BD342_2,$BD410_1,$BD410_2;
while($r1)
{
chomp $r1; chomp $r2;
        if($r1=~m/BD342/g)
        {
                $BD342_1=$BD342_1.$r1.",";
                $BD342_2=$BD342_2.$r2.",";
        }
        else
        {
                $BD410_1=$BD410_1.$r1.",";
                $BD410_2=$BD410_2.$r2.",";
        }
        $r1=<$r1file>;$r2=<$r2file>;
}
print $BD410_1;
system("hisat2","--summary-file BD410.summary","-x /data/embryoDog/UCSC_ref/Dog_ref","-1 ${BD410_1}","-2 ${BD410_2}","-S BD410.sam");
system("echo im working");
close($r2file);
close($r1file);
