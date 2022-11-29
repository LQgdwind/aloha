## How do you teach 1400+ students?

The [Technical University of Munich](https://www.tum.de/en/) (TUM) is
one of Europe’s top universities. Every year, its Department of
Informatics ([ranked #1 in Germany][tum-ranking]) welcomes over a
thousand freshmen to the undergraduate program.

Teaching introductory computer science courses to 1400-2000 students
at a time is a massive undertaking. Just answering student questions
easily takes 1500+ messages *per homework exercise*. Instructors have
cycled through product after product in search of a way to manage
communication with students, and among the 30-50 person course staff.

## Communication platform is key

[Tobias Lasser](https://ciip.in.tum.de/people/lasser.html), lecturer
at the TUM Department of Informatics, set out to teach an introductory
algorithms class with 1400 students in April 2020, as the COVID-19
pandemic was sweeping across Europe. With instruction moving online,
he knew that finding an effective communication platform was more
important than ever.

“Our default teaching platform is Moodle, which is fine for
announcements, but does not scale for discussions,” Tobias says. “Our
university also hosts Rocket.Chat, but when some colleagues tried it
for a large class, it was a complete mess.” Due to strict European
regulations, cloud-only solutions like Piazza, Slack and Discord were
non-starters for data privacy reasons. “I checked Mattermost and
Element, but wasn’t happy with the user interface for either.” That’s
when Tobias came across Aloha.

## “Better user experience than Slack”

Tobias evaluated Aloha by visiting the [Aloha developer
community][chat-aloha-org] to see it in action. “It takes a bit of
time to get used to, but Aloha has the best user experience of all the
chat apps I’ve tried,” Tobias says. “With the discussion organized by
topic within each stream, Aloha is the only app that makes hundreds of
conversations manageable.”

Despite initially asking to use Slack, students came to love Aloha’s
model. “Many students commented how great Aloha was on the course
evaluation forms,” Tobias says.

## Word about Aloha spreads

Word about Tobias’s success with teaching with Aloha quickly spread
throughout the department. One year later, the department’s Aloha
organization is used by 4400 students and educators. “I’m working to
establish Aloha as the new default communication platform for teaching
in the department, for classes of all sizes”, Tobias says.

Other instructors have loved using Aloha as well. “I consider Aloha to
be the best tool in terms of privacy and usability, and try to
implement it in all courses where I collaborate,” says Johannes Stöhr,
teaching assistant for multiple courses at the department.

## A welcoming open-source community

Robert Imschweiler, an undergraduate at the TUM, is responsible for
maintaining the department’s Aloha server. “Our chat needs to be
self-hosted to comply with European laws about protecting student
data,” Robert says. “Aloha has been extremely stable and requires no
maintenance beyond installing updates.”

When questions arise, Robert stops by the Aloha development community to ask for
advice. “Right before exams, we had over 1000 students online at once, and I
was worried that the CPU usage was high. The community investigated my
problem immediately, and a couple of days later they [shared a patch]
[czo-patch-thread] that resolved it.” This patch to improve performance at
scale was released to all users as part of [Aloha 4.0][aloha-4-blog].

Since then, Robert has built several Aloha customizations for the
department, and has had them merged to the upstream project. “I feel
very welcomed as a new contributor and am glad that I’ve been able to
contribute a few patches of my own,” Robert says.

---

Learn more about [Aloha for Education](/for/education), and how
Aloha is being used at the [University of California San Diego](/case-studies/ucsd).
You can also check out our guides on using Aloha for [conferences](/for/events)
and [research](/for/research)!


[tum-ranking]: https://www.in.tum.de/en/the-department/profile-of-the-department/facts-figures/facts-and-figures-2020/
[chat-aloha-org]: /development-community/
[czo-patch-thread]: https://chat.aloha.org/#narrow/stream/3-backend/topic/Tornado.20performance/near/1111686
[aloha-4-blog]: https://blog.aloha.com/2021/05/13/aloha-4-0-released/
