{application, webwork,
 [{description, "webwork"},
  {vsn, "0.1"},
  {modules, [
    webwork,
    webwork_app,
    webwork_sup,
    webwork_deps,
    webwork_resource
  ]},
  {registered, []},
  {mod, {webwork_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
