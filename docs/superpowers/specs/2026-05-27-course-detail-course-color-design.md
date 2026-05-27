# Course Detail Course Color Design

## Context

The `student/course_detail.aspx` page renders the selected course from database-backed detail services. The database seed already stores each course accent in `COURSES.color`, and `CourseDetailService.GetHeader()` already selects that value into `CourseHeader.Color`.

The page currently still hard-codes the red `#e0162b` accent in the header card, tabs, module badges, announcements, assignments, and grade visuals. The user wants the course detail page to use the course color from the database instead.

## Confirmed Requirements

- Use `COURSES.color` from the database for the course detail page.
- Apply the course color to all red accents on `student/course_detail.aspx`.
- Keep the existing page structure and data flow.
- Do not change the database schema.
- Fall back to a neutral slate color when the DB value is missing or malformed.

## Recommended Approach

Use the existing `Header.Color` value and the page's existing `AccentColor(string color)` validator as the single server-side safety gate. Define CSS custom properties on the course detail page, then use those variables for accent styling in markup and JavaScript.

This keeps the change local to the page, avoids repeating inline `<%= AccentColor(Header.Color) %>` everywhere, and lets the JavaScript read the same accent color without duplicating C# validation logic.

## Page Design

The page will expose:

- `--course-accent`: the validated DB color.
- `--course-accent-soft`: a translucent version for pale backgrounds.
- `--course-accent-dark`: a darker interaction color where needed.

The big course header card will use `--course-accent` as the first color in its gradient and keep the existing slate endpoint for contrast.

The following UI accents will switch from fixed red to the course accent:

- Active tab text and tab indicators.
- Module week badges.
- Announcement author avatar and pinned label.
- Assignment icon backgrounds.
- Overall grade donut stroke.
- Score breakdown legend and bars.
- Course pin active color.

Existing neutral slate text, borders, and layout styles stay unchanged.

## JavaScript Design

`js/course-detail/course-detail.js` will read `--course-accent` from the page root or a course detail container and use it for:

- Active tab color.
- Pinned course color.

Inactive tab color remains `#64748b`.

## Error Handling

`AccentColor()` already accepts only six-digit hex values such as `#3b82f6`. Invalid, empty, or null values fall back to `#64748b`.

Because seed data uses valid six-digit hex colors, no seed change is required.

## Testing

Manual verification should cover at least two offerings with different colors:

- CS101 should keep the red course accent.
- CS201, BA101, or IT102 should show blue, amber, or green accents instead of red.

Code verification should confirm no unintended fixed `#e0162b` remains in `student/course_detail.aspx` or `js/course-detail/course-detail.js`, except if intentionally retained outside this page's course accent scope.
