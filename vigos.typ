#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: ellipse as fletcher-ellipse

#set document(title: "vigOS Development Plan", author: "Lars Gerchow")
#set page(margin: 2.5cm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt)
#set heading(numbering: "1.1")
#set par(justify: true)

// Color palette from the project
#let vigOS_light_blue = rgb("#3F98F0")
#let vigOS_dark_blue = rgb("#192B6F")

#align(center)[
  #image("assets/logo/logo_vigOS.svg", width: 8cm)
  #v(1em)
  #text(size: 24pt, weight: "bold")[vigOS Development Plan]
  #v(0.5em)
  #text(size: 14pt)[Versatile Instrumentation and Governance Operating Stack]
]

#v(2em)

= Executive Summary

vigOS is a reusable operating stack for research instruments and data workflows, designed to make FAIR (Findable, Accessible, Interoperable, Reusable) data practices automatic at the point of data creation rather than an afterthought at publication.

#v(1em)

= Problem Statement

// TODO: Expand with specific pain points
- Researchers spend ~10 hours/week on data & code management
- 53% don't know any metadata standards; 30% don't know what they are
- 62% rely on manual file renaming for versioning
- Each new instrument reinvents storage, metadata, governance, and analysis infrastructure
- FAIR compliance typically happens at publication—too late to be reliable

= Vision & Goals

== Primary Goal
Build a modular, reusable infrastructure stack that enables FAIR-by-design research workflows, reducing boilerplate development time by ~50% and freeing researchers from manual data management overhead.

== Key Principles
- *FAIR at source* — metadata captured automatically at acquisition
- *Governance encoded* — policies in code, not spreadsheets
- *Reproducible by default* — containerized environments
- *Build once, reuse everywhere* — modular, composable components