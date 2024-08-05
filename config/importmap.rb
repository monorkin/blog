# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "trix2" # @2.1.4
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.5/dist/esm/index.js"
pin "application", preload: true
pin_all_from "app/javascript/initializers", under: "initializers"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/models", under: "models"
