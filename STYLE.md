# Style

We aim to write code that is a pleasure to read, and we have a lot of opinions about how to do it well. Writing great code is an essential part of our programming culture, and we deliberately set a high bar for every code change anyone contributes. We care about how code reads, how code looks, and how code makes you feel when you read it.

We love discussing code. If you have questions about how to write something, or if you detect some smell you are not quite sure how to solve, please ask away to other programmers. A Pull Request is a great way to do this.

When writing new code, unless you are very familiar with our approach, try to find similar code elsewhere to look for inspiration.

## Conditional returns

In general, we prefer to use expanded conditionals over guard clauses.

```ruby
# Bad
def todos_for_new_group
  ids = params.require(:todolist)[:todo_ids]
  return [] unless ids
  @bucket.recordings.todos.find(ids.split(","))
end

# Good
def todos_for_new_group
  if ids = params.require(:todolist)[:todo_ids]
    @bucket.recordings.todos.find(ids.split(","))
  else
    []
  end
end
```

This is because guard clauses can be hard to read, especially when they are nested.

As an exception, we sometimes use guard clauses to return early from a method:

* When the return is right at the beginning of the method.
* When the main method body is not trivial and involves several lines of code.

```ruby
def after_recorded_as_commit(recording)
  return if recording.parent.was_created?

  if recording.was_created?
    broadcast_new_column(recording)
  else
    broadcast_column_change(recording)
  end
end
```

## Methods ordering

We order methods in classes in the following order:

1. `class` methods
2. `public` methods with `initialize` at the top.
3. `private` methods

## Invocation order

We order methods vertically based on their invocation order. This helps us to understand the flow of the code.

```ruby
class SomeClass
  def some_method
    method_1
    method_2
  end

  private
    def method_1
      method_1_1
      method_1_2
    end

    def method_1_1
      # ...
    end

    def method_1_2
      # ...
    end

    def method_2
      method_2_1
      method_2_2
    end

    def method_2_1
      # ...
    end

    def method_2_2
      # ...
    end
end
```

## Visibility modifiers

We don't add a newline under visibility modifiers, and we indent the content under them.

```ruby
class SomeClass
  def some_method
    # ...
  end

  private
    def some_private_method_1
      # ...
    end

    def some_private_method_2
      # ...
    end
end
```

## To bang or not to bang

Should I call a method `do_something` or `do_something!`?

As a general rule, we only use `!` for methods that have a correspondent counterpart without `!`. In particular, we don't use `!` to flag destructive actions. There are plenty of destructive methods in Ruby and Rails that do not end with `!`.

In this codebase, we use bang methods for operations that perform the work synchronously (e.g., `analyze!`, `generate!`) when there's a corresponding async method (e.g., `analyze_later`, `generate_later`).

## CRUD controllers

We model web endpoints as CRUD operations on resources (REST). When an action doesn't map cleanly to a standard CRUD verb, we introduce a new resource rather than adding custom actions.

```ruby
# Bad
resources :cards do
  post :close
  post :reopen
end

# Good
resources :cards do
  resource :closure
end
```

## Controller and model interactions

In general, we favor a [vanilla Rails](https://dev.37signals.com/vanilla-rails-is-plenty/) approach with thin controllers directly invoking a rich domain model. We don't use services or other artifacts to connect the two.

Invoking plain Active Record operations is totally fine:

```ruby
class Cards::CommentsController < ApplicationController
  def create
    @comment = @card.comments.create!(comment_params)
  end
end
```

For more complex behavior, we prefer clear, intention-revealing model APIs that controllers call directly:

```ruby
class ContentsController < ApplicationController
  def analyze
    @content.pending!
    @content.analyze_later
    redirect_to @content, notice: "Re-analysis started..."
  end
end
```

When justified, it is fine to use services or form objects, but don't treat those as special artifacts:

```ruby
Audio::Transcriber.new(file_path).transcribe
```

## Run async operations in jobs

As a general rule, we write shallow job classes that delegate the logic itself to domain models:

* We typically use the suffix `_later` to flag methods that enqueue a job.
* A common scenario is having a model class that enqueues a job that, when executed, invokes some method in that same class. In this case, we use the suffix `!` for the synchronous method.

```ruby
module Content::Analyzable
  extend ActiveSupport::Concern

  included do
    after_create_commit :analyze_later
  end

  def analyze_later
    AnalyzeContentJob.perform_later(self)
  end

  def analyze!
    # ... actual analysis logic
  end
end

class AnalyzeContentJob < ApplicationJob
  def perform(content)
    content.analyze!
  end
end
```

## Concerns and modules

We use concerns to extract cohesive functionality from models. Include the concern at the top of the model file:

```ruby
class Content < ApplicationRecord
  include Content::Analyzable

  # ... rest of model
end
```

Use `included do` blocks for hooks and associations that need to be defined in the context of the including class:

```ruby
module Content::Analyzable
  extend ActiveSupport::Concern

  included do
    has_many_attached :frames
    after_create_commit :analyze_later
  end

  # ... methods
end
```

## Scopes

Prefer scopes for reusable query logic:

```ruby
class Entity < ApplicationRecord
  scope :by_prominence, -> { order(prominence: :desc) }
  scope :animals, -> { where(entity_type: "animal") }
  scope :plants, -> { where(entity_type: "plant") }
end
```

## Status enums

Use string-backed enums for readability in the database:

```ruby
enum :status, %w[pending processing analyzed failed].index_by(&:itself)
```

## Error handling in jobs

Use job-level error handling directives for retry and discard logic:

```ruby
class GenerateRemixJob < ApplicationJob
  retry_on Comfy::Client::ConnectionError, wait: 30.seconds, attempts: 5
  discard_on Comfy::Client::APIError

  def perform(remix)
    remix.generate!
  end
end
```

## Naming service objects

When creating service objects, name them after what they do (noun form):

```ruby
# Good
Audio::Transcriber.new(file_path).transcribe
Video::FrameExtractor.new(file_path).extract

# Bad
TranscribeAudio.new(file_path).call
ExtractVideoFrames.new(file_path).call
```

## Stimulus controllers

### Privacy

Use JavaScript's native `#` prefix for private methods and instance variables. Everything that isn't part of the public API (actions, target callbacks, lifecycle) should be private.

```javascript
export default class extends Controller {
  #timer
  #fetchController

  // Public action
  submit() {
    if (this.#dirty) this.#save()
  }

  // Private
  #save() {
    // ...
  }

  get #dirty() {
    return !!this.#timer
  }
}
```

### Controller structure

Organize controllers in this order: static declarations, lifecycle, actions, public methods, private methods. Separate sections with a comment.

```javascript
export default class extends Controller {
  static targets = [ "input", "item" ]
  static values = { ... }
  static classes = [ "active" ]

  // Lifecycle

  initialize() { }
  connect() { }
  disconnect() { }

  // Actions

  toggle() { }
  close() { }

  // Public

  selectItem(item) { }

  // Private

  #clearSelection() { }
}
```

### Lifecycle

Use `initialize()` for one-time setup that must happen before the value observer runs (e.g., reading initial DOM state, creating debounced functions). Use `connect()` for setup that depends on targets and values being ready. Use `disconnect()` for cleanup.

```javascript
initialize() {
  this.filter = debounce(this.filter.bind(this), 100)
}
```

Use target callbacks (`targetConnected`/`targetDisconnected`) for dynamic elements instead of manually managing event listeners on targets:

```javascript
imageTargetConnected(element) {
  element.addEventListener("click", this.#handleImageClick)
}

imageTargetDisconnected(element) {
  element.removeEventListener("click", this.#handleImageClick)
}

#handleImageClick = (event) => {
  event.preventDefault()
  this.#open(event.currentTarget)
}
```

### Event handling

Prefer Stimulus actions declared in HTML over manual `addEventListener`. For document or window-level events, use the `@document` or `@window` modifier in `data-action`:

```html
data-action="click@window->dialog#closeOnClickOutside"
```

When manual listeners are truly necessary (e.g., for events Stimulus can't bind), use arrow function class fields so the reference is stable for removal:

```javascript
#handleClick = (event) => { ... }
```

### Outside click

Use a consistent pattern and naming for outside-click handlers:

```javascript
closeOnClickOutside({ target }) {
  if (!this.element.contains(target)) this.close()
}
```

### Keyboard navigation

Use a key handler object instead of a `switch` statement:

```javascript
#keyHandlers = {
  ArrowDown(event) {
    this.#selectNext()
    event.preventDefault()
  },
  ArrowUp(event) {
    this.#selectPrevious()
    event.preventDefault()
  },
  Enter(event) {
    if (event.isComposing) return
    this.#confirmSelection(event)
  }
}

navigate(event) {
  this.#keyHandlers[event.key]?.call(this, event)
}
```

### Debouncing

Create debounced versions of methods in `initialize()` using a shared `debounce` helper. Bind the method so it can be used as an action directly:

```javascript
initialize() {
  this.search = debounce(this.search.bind(this), 200)
}
```

### Naming

Action methods describe *what they do*, not *what event triggered them*. Never prefix actions with `on` — names like `onClick`, `onInput`, `onKeydown` describe the event, not the intent. Instead, name the action after the behavior it performs:

```javascript
// Bad — describes the event
onInput() { ... }
onClick() { ... }
onKeydown() { ... }

// Good — describes the behavior
filter() { ... }
select() { ... }
navigate() { ... }
```

Target names are nouns: `input`, `item`, `label`, `dialog`. Value names describe configuration: `reverseOrder`, `selectionAttribute`, `autoScroll`.

### Constants

Extract magic numbers and timing values into constants at the top of the file:

```javascript
const AUTOSAVE_INTERVAL = 3000
const DEBOUNCE_DELAY = 100
```

### Computed state

Use getters for derived state instead of storing redundant instance variables:

```javascript
get #dirty() {
  return !!this.#timer
}

get #visibleItems() {
  return this.itemTargets.filter(item => !item.hidden)
}
```

### DOM manipulation

Use DOM APIs (`cloneNode`, `appendChild`, `textContent`, `classList`, `toggleAttribute`) rather than building HTML strings with template literals. Clone `<template>` elements for repeating structures. Use `textContent` instead of `innerHTML` when setting text to avoid XSS risks.
