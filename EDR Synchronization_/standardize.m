 function out = standardize(in)
        
        out = in - movmean(in, 50, 'omitnan');
        out = out ./ movstd(out, 50, 'omitnan');
        
 end