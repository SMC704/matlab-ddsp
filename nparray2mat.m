function result = nparray2mat( nparray )
  %nparray2mat Convert an nparray from numpy to a Matlab array
  %   Convert an n-dimensional nparray into an equivalent Matlab array
  data_size = cellfun(@int64,cell(nparray.shape));
  if length(data_size)==1
      % This is a simple operation
      result=double(py.array.array('d', py.numpy.nditer(nparray)));
  elseif length(data_size)==2
      % order='F' is used to get data in column-major order (as in Fortran
      % 'F' and Matlab)
      result=reshape(double(py.array.array('d', ...
          py.numpy.nditer(nparray, pyargs('order', 'F')))), ...
          data_size);
  else
      % For multidimensional arrays more manipulation is required
      % First recover in python order (C contiguous order)
      result=double(py.array.array('d', ...
          py.numpy.nditer(nparray, pyargs('order', 'C'))));
      % Switch the order of the dimensions (as Python views this in the
      % opposite order to Matlab) and reshape to the corresponding C-like
      % array
      result=reshape(result,fliplr(data_size));
      % Now transpose rows and columns of the 2D sub-arrays to arrive at the
      % correct Matlab structuring
      result=permute(result,[length(data_size):-1:1]);
  end
end