alter type "public"."ReactionType" rename to "ReactionType__old_version_to_be_dropped";

create type "public"."ReactionType" as enum ('good', 'cheerup', 'hmmm', 'nope', 'awesome');

alter table "public"."reactions" alter column type type "public"."ReactionType" using type::text::"public"."ReactionType";

drop type "public"."ReactionType__old_version_to_be_dropped";


