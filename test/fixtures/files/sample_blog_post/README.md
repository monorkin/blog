# Sample Blog post

This is a sample blog post that contains each markdown element.

## Quotes

> This is a quote
>
> You can make one by starting the line with a `>` character
>
> -- me

>> You can also double (`>>`),
>> triple (`>>>`) and quadruple (`>>>>`) quote stuff by adding more `>` at the
>> beguiling of a line

>>> But I don't know why you would do that...

>>>> I guess it's nice to have

>>>>> P.S. you can nest quotes as deep as you like

## Code blocks

`this is an inline code block` it's very useful for emphasising `#methods` or
keys like `Ctrl`+`C`.

Then there are the CODE BLOCKS

```ruby
# These are very useful for code snippets and other examples
class Fibonacci
  def compute(x)
    # Asking for the Fibonacci sequence member of a negative number makes no
    # sense, so we just return `nil` immediately
    return if x.negative?

    # The Fibonacci sequence starts with 1, 1 - the 0th member is 1 and the 1st
    # member is 1 - so we can just return the value immediately
    return 1 if x <= 1

    previous = 1
    current = 1

    (x - 1).times do
      new = current + previous
      previous = current
      current = new
    end

    current
  end
end
```

## Common text emphasis

### Italics

One can _italicise_ any text by surrounding it with `_` like so `_example_`.

*Ooooooor* by surrounding it with `*` like so `*example*`.

### Bold

One can __bold__ text by surrounding it with `__` (double `_`) like so
`__example__`.

**Or you can use two asterisks** (double `*`) like so `**example**`.

### Strike through

For situations where you want to say something, ~~but no really~~;
or when you want to correct a ~~mistake~~,
but still show that a mistake was there.

You can reach for a ~~strike through~~ by surrounding the text with `~~` like so
`~~example~~`.

### Links

To create a link wrap text in `[` and `]` then paste the link it leads to right
afterwards surrounded by parenthesis - `(` and `)`.

E.g.
```
[example](https://example.com)
```

Example: [example](https://example.com)

## Lists

One can create many different lists in many different ways.

An unordered list can start with an asteriks `*` or a dash `-` like so:
```
* test
* test

- test
- test
```

Example:
* This item started with an `*`
* This one too
- This one started with a `-`
- And this one too

One can also nest items by indenting them by one tab. E.g.
```
* Test
  * Sub-test
    - Sub-sub-test
      - Fly you fools!
```

Example:
* Test
  * Sub-test
    - Sub-sub-test
      - Fly you fools!

And then there are ordered lists which can start with a number
followed by a dot. E.g.

```
1. Test
2. Test test
```

1. Test
2. Test test

## Images

You can embed images by creating a link to them and prefixing the link with `!`.
The text of the link becomes the alt-text of the image.

E.g.
```
![the alt text for this image](./assets/image.jpeg)
```

Example:
![the alt text for this image](./assets/image.jpeg)

## Videos

Videos can be embedded same as images.
(This is non-standard markdown)

Example:
![the alt text for this video](./assets/video.mp4)
