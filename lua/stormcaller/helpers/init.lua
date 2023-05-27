local M = {}

local catalyst = require("stormcaller.lib.catalyst")
local selection = require("stormcaller.lib.selection")

-------------------------------------------- ...

M.initiate = function(cmd, wanted_text, assert_fn)
    vim.cmd(string.format("norm! %s", cmd))
    catalyst.initiate({ win = 0, buf = 0 })
    assert_fn = assert_fn or M.catalyst_has
    assert_fn(wanted_text)
end

M.initiate_and_check_cursor_positon = function(cmd, wanted_text, assert_fn, pos)
    M.initiate(cmd, wanted_text, assert_fn)
    if not pos then return end
    assert.same(pos, vim.api.nvim_win_get_cursor(0))
end

-------------------------------------------- ...

M.clean_up = function()
    vim.api.nvim_buf_delete(0, { force = true })
    selection.clear()
end

M.set_buf_content = function(content)
    if type(content) == "string" then content = vim.split(content, "\n") end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
end

M.loop = function(times, callback, arguments)
    for _ = 1, times do
        callback(unpack(arguments))
    end
end

-------------------------------------------- Assertions

M.node_has_text = function(node, want)
    local cursor_node_text = vim.treesitter.get_node_text(node, 0)
    assert.equals(want, cursor_node_text)
end

M.node_first_line = function(node, want, buf)
    local cursor_node_text = vim.treesitter.get_node_text(node, buf or 0)
    assert.equals(want, vim.split(cursor_node_text, "\n")[1])
end

-- Catalyst
M.catalyst_has = function(want)
    local cursor_node_text = vim.treesitter.get_node_text(catalyst.node(), catalyst.buf())
    assert.equals(want, cursor_node_text)
end

M.catalyst_first = function(want) M.node_first_line(catalyst.node(), want, catalyst.buf()) end

M.catalyst_last = function(want)
    local cursor_node_text = vim.treesitter.get_node_text(catalyst.node(), catalyst.buf())
    local split = vim.split(cursor_node_text, "\n")
    assert.equals(want, split[#split])
end

M.catalyst_entire_first_line = function(want)
    local start_row = catalyst.node():range()
    local lines = vim.api.nvim_buf_get_lines(catalyst.buf(), start_row, start_row + 1, false)
    assert.equals(want, lines[1])
end

-------------------------------------------- React

M.set_buffer_content_as_react_component = function()
    vim.bo.ft = "typescriptreact"
    M.set_buf_content([[
export default function Home() {
  return (
    <>
      <div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>FAQ</li>
      </div>
    </>
  )
}]])
end

M.set_buffer_content_as_multiple_react_components = function()
    vim.bo.ft = "typescriptreact"
    M.set_buf_content([[
function OtherComponent() {
  return (
    <p>
      Astronauts in space can grow up to 2 inches taller due to the lack of
      gravity.
    </p>
  )
}

let x = 10;
let y = 100;

export default function Home() {
  return (
    <>
      <div className="h-screen w-screen bg-zinc-900">
        <li>Home</li>
        <li>
          A new study found that coffee drinkers have a lower risk of liver
          cancer. So, drink up!
        </li>
        <li>Contacts</li>
        <li>FAQ</li>
        <OtherComponent />
      </div>
    </>
  )
}

let str = "just a random string";

function OtherOtherComponent() {
  return (
    <div>
      <ul>
        <li>Log In</li>
        <li>Sign Up</li>
      </ul>
    </div>
  )
}

import Image from 'next/image'
import { useState } from 'react'

type Image = {
  id: number
  href: string
  imageSrc: string
  name: string
  username: string
}

function cn(...classes: string[]) {
  return classes.filter(Boolean).join(' ')
}

function Gallery({ images }: { images: Image[] }) {
  return (
    <div className="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
      <div className="grid grid-cols-1 gap-x-6 gap-y-10 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 xl:gap-x-8">
        {images.map((image) => (
          <BlurImage key={image.id} image={image}></BlurImage>
        ))}
      </div>
    </div>
  )
}

function BlurImage({ image }: { image: Image }) {
  const [isLoading, setLoading] = useState(true)

  return (
    <a href={image.imageSrc} className="group">
      <div className="aspect-w-1 aspect-h-1 xl:aspect-w-7 xl:aspect-h-8 w-full overflow-hidden rounded-lg bg-gray-200">
        <Image
          alt=""
          src={image.imageSrc}
          fill
          style={{ objectFit: 'cover' }}
          className={cn(
            'duration-700 ease-in-out group-hover:opacity-75',
            isLoading
              ? 'scale-110 blur-2xl grayscale'
              : 'scale-100 blur-0 grayscale-0'
          )}
          onLoadingComplete={() => setLoading(false)}
        />
      </div>
      <h3 className="mt-4 text-sm text-gray-700">{image.name}</h3>
      <p className="mt-1 text-lg font-medium text-gray-900">{image.username}</p>
    </a>
  )
}]])
end

-------------------------------------------- Svelte

M.set_buffer_content_as_svelte_file = function()
    vim.bo.ft = "svelte"
    M.set_buf_content([[
<script>
    import Counter from "./Counter.svelte";
    import welcome from "$lib/images/svelte-welcome.webp";
    import welcome_fallback from "$lib/images/svelte-welcome.png";
</script>

<svelte:head>
    <title>Home</title>
    <meta name="description" content="Svelte demo app" />
</svelte:head>

<section>
    <h1>
        <span class="welcome">
            <picture>
                <source srcset={welcome} type="image/webp" />
                <img src={welcome_fallback} alt="Welcome" />
            </picture>
        </span>

        to your new<br />SvelteKit app
    </h1>

    <h2>
        try editing <strong>src/routes/+page.svelte</strong>
    </h2>

    <Counter />
</section>

<section>
    <h1>Ligma</h1>
    <h3>is a made-up term</h3>
    <p>that gained popularity as part of an Internet prank or meme.</p>
</section>

<style>
    section {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        flex: 0.6;
    }

    h1 {
        width: 100%;
    }

    .welcome {
        display: block;
        position: relative;
        width: 100%;
        height: 0;
        padding: 0 0 calc(100% * 495 / 2048) 0;
    }

    .welcome img {
        position: absolute;
        width: 100%;
        height: 100%;
        top: 0;
        display: block;
    }
</style>]])
end

return M
