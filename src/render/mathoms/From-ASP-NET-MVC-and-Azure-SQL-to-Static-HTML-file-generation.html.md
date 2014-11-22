```
title: "From ASP.NET MVC & Azure SQL to Static HTML file generation"
layout: post
tags: ['.Net','ASP.NET MVC']
date: 10/15/2014 3:30:00 pm
draft: true
ignored : true
render : false
```
A little over a year ago I transitioned my blog from GeeksWithBlogs.net to a Orchard site hosted on Azure. In the the last few months I have been looking hard at what I use to blog and why do I need such a complicated system when most of my content is static.

But now I see something a little different.

Draft: <%= document.draft %>
ignored: <%= document.ignored %>
render: <%= document.render %>