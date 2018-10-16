module DocuTemplatesHelper
  
  def docu_template_status docu_template
    statuses = { :processing => false, :cancelled => false, :signed => false }

    docu_template.docu_signs.each do |value|

      case value.status
      when DocuSign::STATUS_PROCESSING

        statuses[:processing] = true
      when DocuSign::STATUS_CANCELLED

        statuses[:cancelled] = true
      when DocuSign::STATUS_SIGNED

        statuses[:signed] = true
      end
    end

    if statuses[:processing]

      return ('<span class="label label-warning">' + DocuSign::STATUS_PROCESSING.upcase + '</span>').html_safe
    elsif statuses[:cancelled]

      return ('<span class="label label-important">' + DocuSign::STATUS_CANCELLED.upcase + '</span>').html_safe
    elsif statuses[:signed]
    
      return ('<span class="label label-success">' + DocuSign::STATUS_SIGNED.upcase + '</span>').html_safe
    end



    return '<span class="label"> EMPTY </span>'.html_safe
  end

  def docu_sign_status docu_sign
    return ('<span class="label label-warning">'   + DocuSign::STATUS_PROCESSING.upcase  + '</span>').html_safe  if docu_sign.status == DocuSign::STATUS_PROCESSING
    return ('<span class="label label-important">' + DocuSign::STATUS_CANCELLED.upcase   + '</span>').html_safe if docu_sign.status == DocuSign::STATUS_CANCELLED
    return ('<span class="label label-success">'   + DocuSign::STATUS_SIGNED.upcase      + '</span>').html_safe         if docu_sign.status == DocuSign::STATUS_SIGNED

    '<span class="label">EMPTY</span>'.html_safe
  end

end
