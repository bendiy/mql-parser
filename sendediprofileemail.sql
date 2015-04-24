-- Function: xt.sendediprofileemail(text, integer, text, text)

-- DROP FUNCTION xt.sendediprofileemail(text, integer, text, text);

CREATE OR REPLACE FUNCTION xt.sendediprofileemail(doctype text, docid integer, doccontext text default null, options text default '{}')
  RETURNS integer AS
$BODY$

  var params = options.params ? options.params : {},
      ediprofile,
      ediformquery = '',
      editokens,
      edifields,
      ediparams,
      metasqlparams,
      emailto = '',
      emailcc = '',
      emailfrom = '',
      emailreplyto = '',
      emailbcc = '',
      emailsubject = '',
      emailbody = '',
      emailfilename = '',
      batchparams,
      batchid;

  params.doctype = doctype;
  params.docid = docid;
  params.doccontext = doccontext;
  
  /* Get EDI Profile and Form. */
  ediprofile = plv8.execute("SELECT xt.getediprofile($1, $2)", [doctype, docid])[0].getediprofile;
  ediprofile = JSON.parse(ediprofile)[0];

  if (ediprofile.ediform_query) {
    /* Parse ediform_query MetaSQL. */
    metasqlparams = {
      params: params
    };
    ediformquery = plv8.execute("SELECT xt.parsemetasql($1, $2)", [ediprofile.ediform_query, JSON.stringify(metasqlparams)])[0].parsemetasql;

    if (ediformquery) {
      /* Execute the parsed query. */
      editokens = plv8.execute(ediformquery)[0];
    }

    if (editokens) {
      /* Replace EDI tokens with query results. */
      ediparams = {
        params: editokens
      };
      ediparams.params.doctype = doctype;
      ediparams.params.docid = docid;
      ediparams.params.doccontext = doccontext;

      if (ediprofile.ediprofile_option1) {
        emailto = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option1, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediprofile_option4) {
        emailcc = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option4, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediprofile_option5) {
        emailfrom = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option5, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediprofile_option6) {
        emailreplyto = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option6, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediprofile_option7) {
        emailbcc = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option7, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediprofile_option2) {
        emailsubject = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option2, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediprofile_option3) {
        emailbody = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediprofile_option3, JSON.stringify(ediparams)])[0].parseediprofile;
      }
      if (ediprofile.ediform_file) {
        emailfilename = plv8.execute("SELECT xt.parseediprofile($1, $2)", [ediprofile.ediform_file, JSON.stringify(ediparams)])[0].parseediprofile;
      }
    }
  }

  /* Submit email to batch. */
  batchparams = [
    emailfrom,
    emailto,
    emailcc,
    emailsubject,
    emailbody,
    emailfilename,
    ediprofile.ediprofile_emailhtml,
    emailreplyto,
    emailbcc
  ];
  batchid = plv8.execute("SELECT xtbatch.submitEmailToBatch($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, $7, $8, $9)", batchparams)[0].submitemailtobatch;

  return batchid;
$BODY$
  LANGUAGE plv8 IMMUTABLE
  COST 100;

ALTER FUNCTION xt.sendediprofileemail(text, integer, text, text)
  OWNER TO admin;
