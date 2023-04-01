# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "trix2" # @2.0.4
pin "@rails/actiontext", to: "actiontext.js"
# pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.7
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.5/dist/esm/index.js"
pin "application", preload: true
pin_all_from "app/javascript/initializers", under: "initializers"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/models", under: "models"
pin "prism-core" # @2.0.2
pin "#lib/internal/streams/from.js", to: "#lib--internal--streams--from.js.js" # @3.6.2
pin "#lib/internal/streams/stream.js", to: "#lib--internal--streams--stream.js.js" # @2.3.8
pin "#lib/rng.js", to: "#lib--rng.js.js" # @3.3.2
pin "#readable.js" # @2.3.8
pin "#util.inspect.js" # @2.0.1
pin "@babel/runtime/helpers/createForOfIteratorHelper", to: "@babel--runtime--helpers--createForOfIteratorHelper.js" # @7.21.0
pin "@babel/runtime/helpers/objectSpread2", to: "@babel--runtime--helpers--objectSpread2.js" # @7.21.0
pin "@babel/runtime/helpers/slicedToArray", to: "@babel--runtime--helpers--slicedToArray.js" # @7.21.0
pin "@colors/colors/safe", to: "@colors--colors--safe.js" # @1.5.0
pin "@dabh/diagnostics", to: "@dabh--diagnostics.js" # @2.0.3
pin "@google-cloud/common", to: "@google-cloud--common.js" # @0.17.0
pin "@google-cloud/storage", to: "@google-cloud--storage.js" # @1.7.0
pin "@sendgrid/client", to: "@sendgrid--client.js" # @6.5.5
pin "@sendgrid/helpers", to: "@sendgrid--helpers.js" # @6.5.5
pin "@sendgrid/mail", to: "@sendgrid--mail.js" # @6.5.5
pin "accepts" # @1.3.8
pin "after" # @0.8.2
pin "agent-base" # @4.3.0
pin "ajv" # @8.12.0
pin "ajv-keywords" # @5.1.0
pin "ajv/dist/compile/codegen", to: "ajv--dist--compile--codegen.js" # @8.12.0
pin "ajv/lib/refs/json-schema-draft-06.json", to: "ajv--lib--refs--json-schema-draft-06.json.js" # @6.12.6
pin "ansi-bgblack" # @0.1.1
pin "ansi-bgblue" # @0.1.1
pin "ansi-bgcyan" # @0.1.1
pin "ansi-bggreen" # @0.1.1
pin "ansi-bgmagenta" # @0.1.1
pin "ansi-bgred" # @0.1.1
pin "ansi-bgwhite" # @0.1.1
pin "ansi-bgyellow" # @0.1.1
pin "ansi-black" # @0.1.1
pin "ansi-blue" # @0.1.1
pin "ansi-bold" # @0.1.1
pin "ansi-colors" # @0.2.0
pin "ansi-cyan" # @0.1.1
pin "ansi-dim" # @0.1.1
pin "ansi-gray" # @0.1.1
pin "ansi-green" # @0.1.1
pin "ansi-grey" # @0.1.1
pin "ansi-hidden" # @0.1.1
pin "ansi-inverse" # @0.1.1
pin "ansi-italic" # @0.1.1
pin "ansi-magenta" # @0.1.1
pin "ansi-red" # @0.1.1
pin "ansi-reset" # @0.1.1
pin "ansi-strikethrough" # @0.1.1
pin "ansi-styles" # @3.2.1
pin "ansi-underline" # @0.1.1
pin "ansi-white" # @0.1.1
pin "ansi-wrap" # @0.1.0
pin "ansi-yellow" # @0.1.1
pin "apache-crypt" # @1.2.6
pin "apache-md5" # @1.1.8
pin "append-field" # @1.0.0
pin "arr-diff" # @4.0.0
pin "arr-flatten" # @1.1.0
pin "arr-union" # @3.1.0
pin "array-flatten" # @1.1.1
pin "array-sort" # @0.1.4
pin "array-uniq" # @1.0.3
pin "array-unique" # @0.3.2
pin "array.prototype.reduce" # @1.0.5
pin "arraybuffer.slice" # @0.0.7
pin "arrify" # @1.0.1
pin "asap" # @2.0.6
pin "asap/raw", to: "asap--raw.js" # @2.0.6
pin "asap/raw.js", to: "asap--raw.js.js" # @2.0.6
pin "asn1" # @0.2.6
pin "assert" # @2.0.1
pin "assert-plus" # @1.0.0
pin "assign-symbols" # @1.0.0
pin "async" # @2.6.4
pin "async/forEach", to: "async--forEach.js" # @3.2.4
pin "async/series", to: "async--series.js" # @3.2.4
pin "async_hooks" # @2.0.1
pin "autolinker" # @0.28.1
pin "aws-sign2" # @0.7.0
pin "aws4" # @1.12.0
pin "axios" # @0.18.1
pin "axios/lib/adapters/http", to: "axios--lib--adapters--http.js" # @0.18.1
pin "axios/lib/adapters/http.js", to: "axios--lib--adapters--http.js.js" # @0.18.1
pin "balanced-match" # @1.0.2
pin "base" # @0.11.2
pin "base64-arraybuffer" # @0.1.4
pin "base64id" # @2.0.0
pin "bcrypt-pbkdf" # @1.0.2
pin "bcryptjs" # @2.4.3
pin "bee-queue" # @1.5.0
pin "bindings" # @1.5.0
pin "blob" # @0.0.5
pin "bluebird" # @3.7.2
pin "body-parser" # @1.20.1
pin "brace-expansion" # @1.1.11
pin "braces" # @2.3.2
pin "buffer" # @2.0.1
pin "buffer-equal-constant-time" # @1.0.1
pin "buffer-from" # @1.1.2
pin "bull" # @3.29.3
pin "bull-arena" # @2.8.3
