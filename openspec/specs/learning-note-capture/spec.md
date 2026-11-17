# Learning Note Capture Specification

## Purpose

Lets the owner capture the subject notes of the learning system (concept, paper, algorithm, map
of content, architecture) in one step, with the filename and tags that system defines and a body
taken from the notes repository, and keeps every org-roam capture template reachable by its key.

## Requirements

### Requirement: Learning templates
The environment SHALL offer org-roam capture templates for concept, paper, algorithm, map-of-content
and architecture notes, grouped under one key prefix and labelled as learning notes.

#### Scenario: Choosing a learning template
- **WHEN** the user starts an org-roam capture and presses the learning prefix key
- **THEN** the five learning templates are offered, each with its own key

### Requirement: Filename and tag carry the type
Each learning template SHALL create `<timestamp>-<type>-<slug>.org` in the org-roam directory,
where `<type>` is `concept`, `paper`, `algorithm`, `moc` or `arch`, and SHALL set the same type as
a filetag.

#### Scenario: Capturing a concept
- **WHEN** the user captures a concept note titled "Effective index"
- **THEN** the file is named `<timestamp>-concept-effective-index.org` in the org-roam directory, and its filetags include `concept`

### Requirement: Bodies come from the notes repository
Each learning template's body SHALL be read at capture time from `templates/<type>.org` under the
configured org directory, so that a body can change without rebuilding the environment.

#### Scenario: Body edited in the notes repository
- **WHEN** the owner edits `templates/concept.org` in the org directory and then captures a concept note
- **THEN** the new note's body is the edited template, with no rebuild or restart

#### Scenario: Template file missing
- **WHEN** `templates/paper.org` does not exist in the org directory and the user captures a paper note
- **THEN** the capture fails with an error naming the missing file, and no note is created

### Requirement: Template properties are file-level
When a learning template file starts with a property drawer, its properties SHALL be placed in the
new note's file-level property drawer, alongside its ID, and SHALL NOT be repeated in the body.
Other captures SHALL NOT receive them.

#### Scenario: Paper reference from the template
- **WHEN** `templates/paper.org` starts with a drawer setting `:ROAM_REFS: @key` and `:STATUS: stub`, and the user captures a paper note
- **THEN** Org-roam finds the note by the reference `key`, its `STATUS` property is `stub`, and the file has one property drawer, at its top

#### Scenario: Next capture is unaffected
- **WHEN** a note is captured with a non-learning template after a learning capture
- **THEN** it has none of the learning template's properties

### Requirement: One template per note type
For each of the tags `concept`, `paper` and `algorithm`, exactly one org-roam capture template
SHALL set it, namely the learning template for that type.

#### Scenario: Tag means learning note
- **WHEN** any note tagged `concept` is created through org-roam capture
- **THEN** it was made by the learning concept template

### Requirement: Capture keys are unique
Every org-roam capture template, including the existing knowledge, process and scientific
templates, SHALL be reachable by a key or key sequence that no other template uses.

#### Scenario: Selecting the ADR template
- **WHEN** the user selects the template on key `a`
- **THEN** the created note uses the ADR layout and filetag (`adr`), and no other template is bound to `a`

#### Scenario: Duplicate key added later
- **WHEN** a template is added with a key that another template already uses
- **THEN** the configuration test fails and names the key
