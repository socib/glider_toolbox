function data = alignSGDiveParams(data, meta, params)
%ALIGNSGDIVEPARAMS  Align Seaglider dive parameters with column data.
%
%  Syntax:
%    DATA = ALIGNSGDIVEPARAMS(DATA, META, PARAMS)
%
%  Description:
%    DATA = ALIGNSGDIVEPARAMS(DATA, META, PARAMS) aligns the values of 
%    Seaglider dive parameters in the fields of struct DATA selected by
%    character array or string cell array PARAMS with the data column fields.
%    It assigns each parameter value to the first record of the corresponding
%    dive in the final data column, and initializes all other entries as 
%    invalid (NaN).
%
%  Notes:
%    Some parameters like the target waypoint or the currents estimates are
%    provided by Seagliders only once per dive in the log file (.log), and they
%    are not timestamped. This function aligns them with the data collected
%    during the dive as if they were timestamped as the first dive record. For
%    some parameters (e.g. SENSOR_SECS) this might not be the nearest record.
%
%  Examples:
%    data = alignSGDiveParams(data, meta, params)
%
%  See also:
%    LOADSEAGLIDERDATA
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

%  Copyright (C) 2014-2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  error(nargchk(3, 3, nargin, 'struct'));
  
  dive_select = ~cellfun(@isempty, {meta.engheaders.dive}');
  dive_start = vertcat(meta.logheaders(dive_select).start);
  dive_start = [1900 + dive_start(:,3) dive_start(:, [1:2 4:6])];
  dive_start_secs = etime(dive_start, dive_start(ones(size(dive_start,1),1),:));
  record_secs = data.elaps_t;
  delta_secs = bsxfun(@minus, record_secs(:), dive_start_secs(:)');
  delta_secs(delta_secs < 0) = nan;
  [first_records_offsets, first_records_indices] = min(delta_secs);
  dive_with_records = isfinite(first_records_offsets);
  first_records = false(size(record_secs));
  first_records(first_records_indices(dive_with_records)) = true;
  other_records = ~first_records;
  param_name_list = cellstr(params);
  for param_name_idx = 1:numel(param_name_list)
    param_name = param_name_list{param_name_idx};
    if isfield(data, param_name)
      data.(param_name)(first_records) = data.(param_name)(dive_with_records);
      if iscell(data.(param_name))
        data.(param_name)(other_records) = {[]};
      else
        data.(param_name)(other_records) = nan;
      end
    end
  end

end
