# YouTube-DL-Wonder
### A not-so-hastily written polyglot powershell module

## Why?

You can now run the YouTube-DL project portably without having to download the executables or dependencies (or even python thanks to pyenv-win project!), from raw python source code that is available on GitHub.

You can run custom code by extending form this repository, for other websites other than YouTube.  For example, you can use YouTube-DL to scrape the web, you can add more configs to do extra things with more switch flags, etc.  You can extend from this source code to target other websites like Twitch, Instagram, or Facebook if you wanted!

YouTube-DL is very powerful.  It supports far more than the usual Red play button.

## Benefits of YouTube-DL-Wonderful

Not only do you get up-to-date YouTube-DL, PyEnv-win, 7-zip, and ffmpeg dependencies all come with.  There is nothing like chcolatey required or having to screw around with virtualenv configs.  The script does Invoke-WebRequest directly, puts the correct environment configs in portable ``/bin`` folder, and will not touch local user configurations.  This can run from a flash drive, too!  Very Wonderful.

Easily extendable.  Simply modify ``Configure-YouTubeDL`` function to add additional configuration steps such as applying diff patch to target your favorite websites that diff from the vanilla repository to your liking.

## What's provided?

- You get a ``-Video`` switch for automatically downloading YouTube videos in their best quality with automatic conversion to mp4 format.  It works on playlists, too! 

- You get a ``-Music`` switch for automatic extraction of audio tracks from downloaded videos to FLAC (lossless compression) audio format.  It works on playlists, too! 

## Installation

1.  Clone the repository by running git clone https://github.com/loopyd/youtube-dl-wonder.git
2.  Run ``.\run.ps1 -Clean -Install`` to perform initial setup.  
3.  Dump your cookies into ``src/cookiebundle.txt`` using a cookies.txt dumper on YouTube while you are logged in.

Your initial installation is now complete!  You can now move on to the next step.

## Running the application

Simply execute the following command:

```cmd
.\run.ps1 -Run -Video -Url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

And enjoy the output in ``download/videos/``

Now you can run:

```cmd
.\run.ps1 -Run -Music -Url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

To have a flac of the song in ``downlaod/music``.  Since YouTube-DL-Wonderful handles ffmpeg downloading and execution, this is really easy to do for end users, now!

## Possible errors

### Dubious repository

You get the error about a dubious repository.  This is because the repository contains polyglot code that downloads dependnecies for you and contains "YouTubeDL" greylisted words in it.  You can check this in ``run.ps1`` if you are curious, or you can see what GitHub has to say about this project.  It was very controversial and almost taken down once.

```cmd
git config --global --add safe.directory <path_where_you_cloned>
```

## Anit-Piracy and Copyright Law Notice

I am obligated to say that this code is not intended to be used for privacy by design or use case.  It is intended to make it easier for creators to back up their own stuff, or royalty free content in the public domain that belongs to everyone.

As this tool is intended for these uses by its design and its release into the public domain, you are actively  encouraged to refrain from using this tool for malicious purposes or those which may infringe on Copyright Laws or step upon Intellectual Property Rights.  Do not copy work and distribute it that does not belong to you, or anyone else in the public domain.