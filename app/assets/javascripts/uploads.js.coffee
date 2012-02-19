# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@TREE = @TREE || {}

$ ->
  ##
  ## TREE CONFIGURATION
  ##
  TREE.configuration =
    themes:
      theme: "postbox"
      icons: false
    core:
      animation: 100
    html_data:
      ajax:
        url: "/trees/" + TREE.id + "/nodes"
        data: (node) ->
          if node.attr
            $('#' + node.attr('id')).append("<span class=\"jstree-loading\">&nbsp;</span>")
            return { 'parent_id' : node.attr('id') }
          else
            return {}
        error: ->
          $('#tree').find("span.jstree-loading").remove()
    ui:
      select_limit: -1
    plugins: ["themes", "html_data", "ui", "hotkeys"]

  if $.fn.jstree
    $('#tree').jstree(TREE.configuration).bind "open_node.jstree", (event, data) =>
      node = data.rslt
      id = node.obj.attr('id')
      $('#'+id).find("span.jstree-loading").remove()

  $('#tabs').tabs({ selected: 0 })