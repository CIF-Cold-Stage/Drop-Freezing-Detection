function write_txt(file, bounds, mid, conc, sdev, n, meta)

fptr = fopen(file,'w');
fprintf(fptr, 'NC State Cold-Stage: Ice Nucleation Binned Data File\n');
fprintf(fptr, 'Contact Markus Petters (markus_petters@ncsu.edu)\n');
fprintf(fptr, 'North Carolina State University, Raleigh, North Carolina, USA\n');
fprintf(fptr, '------------------------------------------------------------\n');
fprintf(fptr, 'Tl (C)            lower bin edge temperature\n');
fprintf(fptr, 'Tmid (C)          temperature mid point\n');
fprintf(fptr, 'Tu (C)            upper bin edge\n');
fprintf(fptr, 'Cin (# L-1)       mean INP concentration per L of H2O\n');
fprintf(fptr, 'sigma Cin (# L-1) 1 sigma INP concentration per L of H2O\n');
fprintf(fptr, 'n (-)             number of freeze events\n');
fprintf(fptr, '------------------------------------------------------------\n');
fprintf(fptr, 'Sample description           %s\n', meta.sampleType);
fprintf(fptr, 'Data collected               %s\n', meta.dateCollected);
fprintf(fptr, 'Number of repeats            %i\n', meta.repeats);
fprintf(fptr, 'Date analyzed                %s\n', meta.analyzed{:});
fprintf(fptr, 'Date validated               %s\n', meta.validated{:});
fprintf(fptr, 'Drop volume (L)              %.2e\n', meta.Vdrop);
fprintf(fptr, 'Stage cooling rate (K min-1) %i\n', meta.coolingRate);
fprintf(fptr, 'Data originator              %s\n', meta.originator);
fprintf(fptr, '------------------------------------------------------------\n');
fprintf(fptr, '   Tl    Tmid   Tu       Cin        sigma      n\n');
for i = 1:numel(mid)
    fprintf(fptr, '%6.1f, %6.1f, %6.1f, %10.2e, %10.2e, %5i\n', ...
        bounds(i), mid(i), bounds(i+1), conc(i), sdev(i), n(i));
end
fclose(fptr);
