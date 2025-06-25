// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}

#let poster(
  // The poster's size.
  size: "'36x24' or '48x36''",

  // The poster's title.
  title: "Paper Title",

  // A string of author names.
  authors: "Author Names (separated by commas)",

  // Department name.
  departments: "Department Name",

  // University logo.
  univ_logo: "Logo Path",

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
  footer_text: "Footer Text",

  // Any URL, like a link to the conference website.
  footer_url: "Footer URL",

  // Email IDs of the authors.
  footer_email_ids: "2301140@sit.singaporetech.edu.sg",

  // Color of the footer.
  footer_color: "Hex Color Code",
  
  // Text color of the footer.
  footer_text_color: "Hex Color Code",

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
  keywords: (),

  // Number of columns in the poster.
  num_columns: "3",

  // University logo's scale (in %).
  univ_logo_scale: "50",

  // University logo's column size (in in).
  univ_logo_column_size: "10",

  // Title and authors' column size (in in).
  title_column_size: "20",

  // Poster title's font size (in pt).
  title_font_size: "42",

  // Authors' font size (in pt).
  authors_font_size: "34",

  // Footer's URL and email font size (in pt).
  footer_url_font_size: "28",

  // Footer's text font size (in pt).
  footer_text_font_size: "35",

  // The poster's content.
  body
) = {
  // Set the body font.
  set text(font: "STIX Two Text", size: 15.2pt)
  let sizes = size.split("x")
  let width = int(sizes.at(0)) * 1in
  let height = int(sizes.at(1)) * 1in
  univ_logo_scale = int(univ_logo_scale) * 1%
  title_font_size = int(title_font_size) * 1pt
  authors_font_size = int(authors_font_size) * 1pt
  num_columns = int(num_columns)
  univ_logo_column_size = int(univ_logo_column_size) * 1in
  title_column_size = int(title_column_size) * 1in
  footer_url_font_size = int(footer_url_font_size) * 1pt
  footer_text_font_size = int(footer_text_font_size) * 1pt

  // Configure the page.
  // This poster defaults to 36in x 24in.
  set page(
    width: width,
    height: height,
    margin: 
      (top: 1in, left: 1.75in, right: 1.75in, bottom: 2in),
    footer: [
      #set align(right)
      #set text(32pt, white)
      #block(
        fill: rgb(228,51,44),
        width: 100%,
        inset: 20pt,
        radius: 10pt,
        [
          //#text(font: "Courier", size: footer_url_font_size, footer_url) 
          //#h(1fr) 
          #text(size: footer_text_font_size, smallcaps(footer_text)) 
          #h(1fr) 
          #text(font: "Courier", size: footer_url_font_size, footer_email_ids)
        ]
      )
    ]
  )
  
  
// Better image handling in columns
show figure: it => {
  set block(breakable: false, spacing: 0.6em)
  set align(center)
  
  // Reduce spacing around images to fit better in columns
  block(above: 0.5em, below: 0.8em, it)
}

// Tighter spacing for content after column breaks
show heading: it => context {
  let loc = here()
  let levels = counter(heading).at(loc)
  let deepest = if levels != () {
    levels.last()
  } else {
    1
  }

  set block(breakable: false)
  
  set text(24pt, weight: 400)
  if it.level == 1 [
    #set align(center)
    #set text({ 32pt })
    #show: smallcaps
    #v(15pt, weak: true)  // Reduced from 30pt
    #if it.numbering != none {
      numbering("I.", deepest)
      h(7pt, weak: true)
    }
    #it.body
    #v(10pt, weak: true)  // Reduced from 20pt
    #line(length: 100%)
    #v(8pt, weak: true)   // Reduced from 15pt
  ] else if it.level == 2 [
    #set text(style: "italic")
    #v(15pt, weak: true)  // Reduced from 25pt
    #if it.numbering != none {
      numbering("i.", deepest)
      h(7pt, weak: true)
    }
    #it.body
    #v(8pt, weak: true)   // Reduced from 10pt
  ] else [
    #v(10pt, weak: true)  // Reduced from 15pt
    #if it.level == 3 {
      numbering("1)", deepest)
      [ ]
    }
    _#(it.body):_
    #v(6pt, weak: true)   // Reduced from 8pt
  ]
}
  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure figures to stay with their content and improve spacing
  show figure: it => {
    set block(breakable: false, spacing: 1.2em)
    set align(center)
    block(
      above: 0.8em,
      below: 1.2em,
      it
    )
  }

  // Configure headings.
  //set heading(numbering: "I.A.1.")
  show heading: it => context {
    let loc = here()
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    // Ensure headings stay with their content
    set block(breakable: false)
    
    set text(24pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      #set align(center)
      #set text({ 32pt })
      #show: smallcaps
      #v(30pt, weak: true)
      #if it.numbering != none {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(20pt, weak: true)
      #line(length: 100%)
      #v(15pt, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set text(style: "italic")
      #v(25pt, weak: true)
      #if it.numbering != none {
        numbering("i.", deepest)
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #v(15pt, weak: true)
      #if it.level == 3 {
        numbering("1)", deepest)
        [ ]
      }
      _#(it.body):_
      #v(8pt, weak: true)
    ]
  }

  // Arranging the logo, title, authors, and department in the header.
  align(center,
    grid(
      rows: 2,
      columns: (title_column_size, univ_logo_column_size),
      column-gutter: 0pt,
      row-gutter: 50pt,
      text(title_font_size, title + "\n\n") + 
      text(authors_font_size, emph("Team Navy\n")) + 
      text(authors_font_size, emph(authors) + 
          "   (" + departments + ") "),
      image(univ_logo, width: univ_logo_scale),
    )
  )

  // Start three column mode and configure paragraph properties.
  show: columns.with(num_columns, gutter: 64pt)
  set par(justify: true, first-line-indent: 0em)
  set par(spacing: 0.65em)

  // Display the keywords.
  if keywords != () [
      #set text(24pt, weight: 400)
      #show "Keywords": smallcaps
      *Keywords* --- #keywords.join(", ")
  ]

  // Display the poster's contents.
  body
}
#import "@preview/fontawesome:0.1.0": *

// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => poster(
   title: [Singapore Election Trends Analysis], 
  // TODO: use Quarto's normalized metadata.
   authors: [Dan Lai Kai Yi, Ng Jia Wei, Suresh Kumar Balavignesh, Kumar Devadharshini, Putri Nadrah Binte Jefreydin, Tan De Wei], 
   departments: [School of Computing, Singapore Institute of Technology], 
   size: "36x24", 

  // Institution logo.
   univ_logo: "./images/sit-logo.png", 

  // Footer text.
  // For instance, Name of Conference, Date, Location.
  // or Course Name, Date, Instructor.
   footer_text: [Singapore Election Trends Analysis], 

  // Any URL, like a link to the conference website.
  

  // Emails of the authors.
  

  // Color of the footer.
   footer_color: "ebcfb2", 

  // DEFAULTS
  // ========
  // For 3-column posters, these are generally good defaults.
  // Tested on 36in x 24in, 48in x 36in, and 36in x 48in posters.
  // For 2-column posters, you may need to tweak these values.
  // See ./examples/example_2_column_18_24.typ for an example.

  // Any keywords or index terms that you want to highlight at the beginning.
   keywords: ("Elections", "Data Analysis", "Visualization", "Singapore"), 

  // Number of columns in the poster.
  

  // University logo's scale (in %).
  

  // University logo's column size (in in).
  

  // Title and authors' column size (in in).
  

  // Poster title's font size (in pt).
  

  // Authors' font size (in pt).
  

  // Footer's URL and email font size (in pt).
  

  // Footer's text font size (in pt).
  

  doc,
)

= Introduction
<introduction>
This analysis explores the trends and patterns in Singapore’s Parliamentary General Elections, focusing on historical data to uncover insights about voting patterns, constituency changes, and electoral dynamics over time.

= Data Sources
<data-sources>
Our analysis utilizes official election data from:

- #strong[Elections Department Singapore (ELD)];: Parliamentary General Election Results, candidate information, and voter statistics from https:\/\/www.eld.gov.sg/homepage.html
- #strong[Regional Classification];: Manual processing to classify constituencies into regions based on Urban Redevelopment Authority (URA) planning areas from https:\/\/www.ura.gov.sg/Corporate

= Methodology & Tools
<methodology-tools>
Our analytical approach combines:

- #strong[Python] for data preprocessing and statistical analysis
- #strong[R & ggplot2] for advanced visualization
- #strong[Quarto] for reproducible research documentation \
- #strong[Specialized libraries] including tidyverse and plotly

= Original Visualization
<original-visualization>
#figure([
#box(image("./images/previous_visualization.png", width: 70%))
], caption: figure.caption(
position: bottom, 
[
Previous visualization of election data
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


#strong[Figure 1:] Previous visualization approach

The original visualization presented several challenges: limited visual hierarchy, minimal interactive capabilities, basic color schemes lacking accessibility, and dense information presentation.

= Enhanced Visualization
<enhanced-visualization>
#figure([
#box(image("./images/improved_visualization.png", width: 70%))
], caption: figure.caption(
position: bottom, 
[
Enhanced visualization with better insights
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)


#strong[Figure 2:] Enhanced visualization with modern principles

== Key Improvements
<key-improvements>
Our redesigned visualization addresses previous limitations:

- #strong[Accurate Percentage Representation];: Vote share percentages now correctly add up to 100%, eliminating mathematical inconsistencies in the original visualization
- #strong[Clear Trend Indicators];: Implementation of up/down trend tickers (↗ ↘) providing immediate visual cues for electoral performance changes across election cycles
- #strong[Interactive Data Exploration];: Enhanced hover tooltips and filtering options for deeper data analysis
- #strong[Improved Visual Hierarchy];: Clear sectioning with progressive information disclosure
- #strong[Accessibility-First Design];: Color-blind friendly palettes with high contrast ratios
- #strong[Regional Classification];: Constituencies grouped by URA planning regions for meaningful geographic analysis

= Research Impact
<research-impact>
#block[
#callout(
body: 
[
Our enhanced visualization offers significant advantages:

#strong[Accessibility & Inclusion] - Makes complex electoral data comprehensible to diverse audiences - Implements universal design principles - Reduces barriers to civic engagement

#strong[Analytical Depth] - Enables identification of subtle voting patterns \
\- Facilitates comparative analysis across constituencies - Supports evidence-based political discourse

#strong[Engagement & Education] - Increases reader interaction and comprehension - Supports multimedia storytelling approaches - Enhances public understanding of democratic processes

#strong[Editorial Advantages] - Streamlines complex data presentation workflows - Enables rapid adaptation for different story angles - Provides reusable templates for future coverage

This toolkit represents a significant advancement in electoral data presentation.

]
, 
title: 
[
Editorial Board Proposal
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
= Key Findings & Insights
<key-findings-insights>
Our analysis revealed several significant trends in Singapore’s electoral landscape:

== Voter Participation Trends
<voter-participation-trends>
- #strong[Increasing Turnout];: Steady rise in voter participation from 1988 to 2020
- #strong[Demographic Shifts];: Notable changes in age group voting patterns
- #strong[Geographic Variations];: Distinct voting behaviors across different constituencies

== Electoral Competition Patterns
<electoral-competition-patterns>
- #strong[Multi-party Evolution];: Growth in opposition party participation
- #strong[Constituency Changes];: Impact of electoral boundary modifications
- #strong[Candidate Diversity];: Increasing representation across demographic groups
