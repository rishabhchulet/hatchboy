module DocuTemplatesHelper
  def docu_template_status docu_template
    ret_val = '<span class="label"> EMPTY </span>'

    docu_template.docu_signs.each do |value|
      return if value.status == DocuSign::STATUS_PROCESSING
      if value.status == DocuSign::STATUS_CANCELLED
        ret_val = '<span class="label label-important">' + DocuSign::STATUS_CANCELLED.upcase + '</span>'
        break
      elsif value.status == DocuSign::STATUS_PROCESSING
        ret_val = '<span class="label label-warning">' + DocuSign::STATUS_PROCESSING.upcase + '</span>'
        break
      end
      ret_val = '<span class="label label-success">' + DocuSign::STATUS_SIGNED.upcase + '</span>'
    end

    return ret_val.html_safe
  end

  def docu_sign_status docu_sign
    return ('<span class="label label-warning">'   + DocuSign::STATUS_PROCESSING.upcase  + '</span>').html_safe  if docu_sign.status == DocuSign::STATUS_PROCESSING
    return ('<span class="label label-important">' + DocuSign::STATUS_CANCELLED.upcase   + '</span>').html_safe if docu_sign.status == DocuSign::STATUS_CANCELLED
    return ('<span class="label label-success">'   + DocuSign::STATUS_SIGNED.upcase      + '</span>').html_safe         if docu_sign.status == DocuSign::STATUS_SIGNED

    '<span class="label">EMPTY</span>'.html_safe
  end
end
