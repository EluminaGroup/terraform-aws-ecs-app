data "aws_route53_zone" "selected" {
  count        = var.hosted_zone_id == "" && var.alb_only && var.hostname_create ? 1 : 0
  name         = var.hosted_zone
  private_zone = var.hosted_zone_is_internal
}

resource "aws_route53_record" "hostnames" {
  for_each = (!var.hosted_zone_is_internal && var.alb_only && var.hostname_create && length(var.hostnames) != 0) ? zipmap(var.hostnames, var.hostnames) : {}

  zone_id = var.hosted_zone_id == "" ? data.aws_route53_zone.selected[0].zone_id : var.hosted_zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}

resource "aws_route53_record" "extra_hostnames" {
  for_each = (!var.hosted_zone_is_internal && var.alb_only && var.hostname_create && length(var.extra_hostnames) != 0) ? zipmap(var.extra_hostnames, var.extra_hostnames) : {}

  zone_id = var.hosted_zone_id == "" ? data.aws_route53_zone.selected[0].zone_id : var.hosted_zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}


data "aws_lb" "alb_selected" {
  count = var.hosted_zone_is_internal && var.alb_only && var.hostname_create && length(var.hostnames) != 0 ? length(var.hostnames) : 0
  name  = var.alb_name
}

resource "aws_route53_record" "hostnames_internal" {
  count   = var.hosted_zone_is_internal && var.alb_only && var.hostname_create && length(var.hostnames) != 0 ? length(var.hostnames) : 0
  zone_id = var.hosted_zone_id == "" ? data.aws_route53_zone.selected.*.zone_id[0] : var.hosted_zone_id
  name    = var.hostnames[count.index]
  type    = "A"
  alias {
    name                   = data.aws_lb.alb_selected.*.dns_name[0]
    zone_id                = data.aws_lb.alb_selected.*.zone_id[0]
    evaluate_target_health = true
  }
}
