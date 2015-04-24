-- Function: xt.getediprofile(text, integer, text, text)

-- DROP FUNCTION xt.getediprofile(text, integer, text, text);

CREATE OR REPLACE FUNCTION xt.getediprofile(doctype text, docid integer, doccontext text default null, options text default '{}')
  RETURNS text AS
$BODY$

  var sql = 'SELECT * ' +
            'FROM xtbatch.ediprofile ' +
            'LEFT OUTER JOIN xtbatch.ediform ON ( ' +
            ' (ediform_ediprofile_id = ediprofile_id)' +
            ' AND (ediform_type=$1))' +
            'WHERE ediprofile_id = ',
      getediprofileid = '',
      profile,
      result,
      params = [doctype, docid, doccontext];

  if (doctype === 'REG') {
    // TODO: query to get the ediprofile_id for this type
  } else if (doctype === 'REGMGMT') {
    // TODO: query to get the ediprofile_id for this type
  } else if (doctype === 'TODO') {
    // TODO: query to get the ediprofile_id for all the other regmgmt types.
  } else {
    getediprofileid = ' xtbatch.getEDIProfileId($1, $2, $3) ';
  }

  sql += getediprofileid;

  /**
   * Call the above parser with this functions parameters.
   */
  try {
plv8.elog(WARNING, sql);
    profile = plv8.execute(sql, params);
    result = JSON.stringify(profile);
  } catch (err) {
    // Mimic mobilized XT.error() style error message.
    var message = {
      code: 500, 
      message: 'Cannot get EDI Profile.' + err
    };
    
    plv8.elog(ERROR, JSON.stringify(message));
  }
  
  return result;
$BODY$
  LANGUAGE plv8 IMMUTABLE
  COST 100;

ALTER FUNCTION xt.getediprofile(text, integer, text, text)
  OWNER TO admin;
