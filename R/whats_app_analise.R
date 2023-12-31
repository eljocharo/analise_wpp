

  library(tidyverse)


   library(rwhatsapp)

  usethis::use_git_config( user.name = "eljocharo",
                           user.email = "joel.rocha.souza@gmail.com")

usethis::use_git()

usethis::use_github()

  chat <- rwa_read("data-raw/balanca_mais_nao_cai.txt") %>%
    filter(!is.na(author)) %>%
    mutate(author = gsub("Marcelo BAHIA", "Marcelo Lima", author))
  # remove messages without author

   chat  %>%
     count(author, sort = T)




   chat %>%
     mutate(day = date(time)) %>%
     count(day) %>%
     ggplot(aes(x = day, y = n)) +
     geom_bar(stat = "identity") +
     ylab("") + xlab("") +
     ggtitle("Messages per day")


   chat %>%
     mutate(day = date(time)) %>%
     count(author) %>%
     ggplot(aes(x = reorder(author, n), y = n)) +
     geom_bar(stat = "identity") +
     ylab("") + xlab("") +
     coord_flip() +
     ggtitle("Number of messages")



   library("tidyr")
   chat %>%
     unnest(emoji) %>%
     count(author, emoji, sort = TRUE) %>%
     group_by(author) %>%
     top_n(n = 6, n) %>%
     ggplot(aes(x = reorder(emoji, n), y = n, fill = author)) +
     geom_col(show.legend = FALSE) +
     ylab("") +
     xlab("") +
     coord_flip() +
     facet_wrap(~author, ncol = 2, scales = "free_y")  +
     ggtitle("Most often used emojis")


   library("ggimage")

   emoji_data <- rwhatsapp::emojis %>% # data built into package
     mutate(hex_runes1 = gsub("\\s.*", "", hex_runes)) %>% # ignore combined emojis
     mutate(emoji_url = paste0("https://abs.twimg.com/emoji/v2/72x72/",
                               tolower(hex_runes1), ".png"))

   chat %>%
     unnest(emoji) %>%
     count(author, emoji, sort = TRUE) %>%
     group_by(author) %>%
     top_n(n = 6, n) %>%
     left_join(emoji_data, by = "emoji") %>%
     ggplot(aes(x = reorder(emoji, n), y = n, fill = author)) +
     geom_col(show.legend = FALSE) +
     ylab("") +
     xlab("") +
     coord_flip() +
     geom_image(aes(y = n + 20, image = emoji_url)) +
     facet_wrap(~author, ncol = 2, scales = "free_y") +
     ggtitle("Most often used emojis") +
     theme(axis.text.y = element_blank(),
           axis.ticks.y = element_blank())



   library("tidytext")

   chat %>%
     unnest_tokens(input = text,
                   output = word) %>%
     count(author, word, sort = TRUE) %>%
     group_by(author) %>%
     top_n(n = 6, n) %>%
     ggplot(aes(x = reorder_within(word, n, author), y = n, fill = author)) +
     geom_col(show.legend = FALSE) +
     ylab("") +
     xlab("") +
     coord_flip() +
     facet_wrap(~author, ncol = 2, scales = "free_y") +
     scale_x_reordered() +
     ggtitle("Most often used words")


     library("stopwords")

     to_remove <- c(stopwords(language = "pt"),
                    "de",
                    "mídia",
                    "arquivo",
                    "oculto",
                    "o",
                    "ja",
                    "que",
                    "é", "tá", "pra", "ai", "vc", "https", "kkk", "aí", "cara")

     chat %>%
       unnest_tokens(input = text,
                     output = word) %>%
       filter(!word %in% to_remove) %>%
       count(author, word, sort = TRUE) %>%
       group_by(author) %>%
       top_n(n = 6, n) %>%
       ggplot(aes(x = reorder_within(word, n, author), y = n, fill = author)) +
       geom_col(show.legend = FALSE) +
       ylab("") +
       xlab("") +
       coord_flip() +
       facet_wrap(~author, ncol = 2, scales = "free_y") +
       scale_x_reordered() +
       ggtitle("Most often used words")


     chat %>%
       unnest_tokens(input = text,
                     output = word) %>%
       select(word, author) %>%
       filter(!word %in% to_remove) %>%
       mutate(word = gsub(".com", "", word)) %>%
       mutate(word = gsub("^gag", "9gag", word)) %>%
       count(author, word, sort = TRUE) %>%
       bind_tf_idf(term = word, document = author, n = n) %>%
       # filter(n > 10) %>%
       group_by(author) %>%
       top_n(n = 6, tf_idf) %>%
       ggplot(aes(x = reorder_within(word, n, author), y = n, fill = author)) +
       geom_col(show.legend = FALSE) +
       ylab("") +
       xlab("") +
       coord_flip() +
       facet_wrap(~author, ncol = 2, scales = "free_y") +
       scale_x_reordered() +
       ggtitle("Important words using balança mais não cai")


     chat %>%
       unnest_tokens(input = text,
                     output = word) %>%
       filter(!word %in% to_remove) %>%
       group_by(author) %>%
       summarise(lex_diversity = n_distinct(word)) %>%
       arrange(desc(lex_diversity)) %>%
       ggplot(aes(x = reorder(author, lex_diversity),
                  y = lex_diversity,
                  fill = author)) +
       geom_col(show.legend = FALSE) +
       scale_y_continuous(expand = (mult = c(0, 0, 0, 500))) +
       geom_text(aes(label = scales::comma(lex_diversity)), hjust = -0.1) +
       ylab("unique words") +
       xlab("") +
       ggtitle("Lexical Diversity") +
       coord_flip()


     o_words <- chat %>%
       unnest_tokens(input = text,
                     output = word) %>%
       filter(author != "Joel Rocha") %>%
       count(word, sort = TRUE)

     chat %>%
       unnest_tokens(input = text,
                     output = word) %>%
       filter(author == "Joel Rocha") %>%
       count(word, sort = TRUE) %>%
       filter(!word %in% o_words$word) %>% # only select words nobody else uses
       top_n(n = 6, n) %>%
       ggplot(aes(x = reorder(word, n), y = n)) +
       geom_col(show.legend = FALSE) +
       ylab("") + xlab("") +
       coord_flip() +
       ggtitle("Unique words of Joel Rocha")
