QuoteOP =
  init: ->
    return if g.VIEW is 'catalog' or !Conf['Mark OP Quotes']

    if Conf['Comment Expansion']
      ExpandComment.callbacks.push @node

    # \u00A0 is nbsp
    @text = '\u00A0(OP)'
    Post::callbacks.push
      name: 'Mark OP Quotes'
      cb:   @node

  node: ->
    # Stop there if it's a clone of a post in the same thread.
    return if @isClone and @thread is @context.thread
    # Stop there if there's no quotes in that post.
    return unless (quotes = @quotes).length
    {quotelinks} = @nodes

    # rm (OP) from cross-thread quotes.
    if @isClone and quotes.contains @thread.fullID
      i = 0
      while quotelink = quotelinks[i++]
        quotelink.textContent = quotelink.textContent.replace QuoteOP.text, ''

    {fullID} = (if @isClone then @context else @).thread
    # add (OP) to quotes quoting this context's OP.

    return unless quotes.contains fullID
    i = 0
    while quotelink = quotelinks[i++]
      {boardID, postID} = Get.postDataFromLink quotelink
      if "#{boardID}.#{postID}" is fullID
        $.add quotelink, $.tn QuoteOP.text
    return
