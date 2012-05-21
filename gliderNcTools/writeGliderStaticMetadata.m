function writeGliderStaticMetadata(filename)

% File Metadata
    nc_attput(filename, NC_GLOBAL, 'Conventions', 'CF-1.5');
    nc_attput(filename, NC_GLOBAL, 'netcdf_version', '3.6.4');
    nc_attput(filename, NC_GLOBAL, 'title', 'Data from glider');
    nc_attput(filename, NC_GLOBAL, 'type', 'Glider data file');
    nc_attput(filename, NC_GLOBAL, 'summary', 'Glider Mission in Balearic Sea');
    nc_attput(filename, NC_GLOBAL, 'cdm_data_type', 'Trajectory');
    nc_attput(filename, NC_GLOBAL, 'featureType', 'trajectory');
    nc_attput(filename, NC_GLOBAL, 'data_mode', 'R');

% Project and Provider Metadata
    nc_attput(filename, NC_GLOBAL, 'data_center', 'SOCIB Data Center');
    nc_attput(filename, NC_GLOBAL, 'data_center_email', 'info@socib.es');
    nc_attput(filename, NC_GLOBAL, 'institution', 'SOCIB (Sistema de Observacion y prediccion Costero de las Islas Baleares)');
    nc_attput(filename, NC_GLOBAL, 'institution_references', 'http://www.socib.es');
    nc_attput(filename, NC_GLOBAL, 'principal_investigator', 'Prof. Joaquim Tintore Subirana');
    nc_attput(filename, NC_GLOBAL, 'principal_investigator_email', 'jtintore@socib.es');
    nc_attput(filename, NC_GLOBAL, 'project', 'SOCIB Operational');
    nc_attput(filename, NC_GLOBAL, 'author', 'Benjamin Casas Perez');
    nc_attput(filename, NC_GLOBAL, 'author_email', 'bcasas@socib.es');
    nc_attput(filename, NC_GLOBAL, 'creator_name', 'Benjamin Casas Perez');
    nc_attput(filename, NC_GLOBAL, 'creator_url', 'http://www.imedea.uib.es/~benjamin/index.php');
    nc_attput(filename, NC_GLOBAL, 'creator_email', 'bcasas@socib.es');
    nc_attput(filename, NC_GLOBAL, 'publisher_name', 'SOCIB');
    nc_attput(filename, NC_GLOBAL, 'publisher_url', 'http://www.socib.es');
    nc_attput(filename, NC_GLOBAL, 'publisher_email', 'info@socib.es');
    nc_attput(filename, NC_GLOBAL, 'distribution_statement', 'Approved for public release. Distribution Unlimited.');
    nc_attput(filename, NC_GLOBAL, 'license', 'Approved for public release. Distribution Unlimited.');
    nc_attput(filename, NC_GLOBAL, 'citation', 'Balearic Island Coastal and Observing Forecasting System.');
    nc_attput(filename, NC_GLOBAL, 'acknowledgement', 'Ministerio de ciencia e innovacion (http://www.micinn.es/). Govern de les Illes Balears (http://www.caib.es/).');

% Platform Metadata
    nc_attput(filename, NC_GLOBAL, 'trans_system', 'IRIDIUM');
    nc_attput(filename, NC_GLOBAL, 'positioning_system', 'GPS');
    nc_attput(filename, NC_GLOBAL, 'platform_model', 'WEBB SLOCUM');
    nc_attput(filename, NC_GLOBAL, 'platform_maker', 'Webb Research Corporation');
    nc_attput(filename, NC_GLOBAL, 'anomaly', 'none');

end